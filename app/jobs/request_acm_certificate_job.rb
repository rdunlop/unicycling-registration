class RequestAcmCertificateJob < ApplicationJob
  queue_as :default

  def perform(tenant_alias_id)
    tenant_alias = TenantAlias.find_by(id: tenant_alias_id)
    return unless tenant_alias
    return if tenant_alias.acm_cert_issued?

    acm = Aws::ACM::Client.new(region: ENV.fetch("AWS_REGION", "us-east-1"))

    response = acm.request_certificate(
      domain_name: tenant_alias.website_alias,
      validation_method: "DNS",
      subject_alternative_names: [tenant_alias.website_alias]
    )
    cert_arn = response.certificate_arn

    # Retrieve the DNS validation CNAME record (may take a few seconds to populate)
    cname_name, cname_value = fetch_validation_cname(acm, cert_arn)

    tenant_alias.update!(
      acm_certificate_arn: cert_arn,
      acm_cert_status: "pending",
      acm_dns_validation_cname_name: cname_name,
      acm_dns_validation_cname_value: cname_value
    )

    PollAcmCertificateJob.set(wait: 5.minutes).perform_later(tenant_alias_id)
  rescue Aws::ACM::Errors::ServiceError => e
    Rails.logger.error("ACM certificate request failed for TenantAlias #{tenant_alias_id}: #{e.message}")
    tenant_alias&.update(acm_cert_status: "failed")
  end

  private

  def fetch_validation_cname(acm, cert_arn, attempts: 6)
    attempts.times do
      cert = acm.describe_certificate(certificate_arn: cert_arn).certificate
      option = cert.domain_validation_options&.first
      if option&.resource_record
        return [option.resource_record.name, option.resource_record.value]
      end

      sleep 5
    end
    [nil, nil]
  end
end
