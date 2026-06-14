class PollAcmCertificateJob < ApplicationJob
  queue_as :default

  # Poll at most 48 times (every 1h → covers 48h for DNS propagation + validation)
  MAX_ATTEMPTS = 48

  def perform(tenant_alias_id, attempt: 1)
    tenant_alias = TenantAlias.find_by(id: tenant_alias_id)
    return unless tenant_alias
    return if tenant_alias.acm_cert_issued?

    acm = Aws::ACM::Client.new(region: ENV.fetch("AWS_REGION", "us-east-1"))
    cert = acm.describe_certificate(certificate_arn: tenant_alias.acm_certificate_arn).certificate

    # Pick up validation CNAME if it wasn't available when the cert was first requested
    if !tenant_alias.acm_validation_configured? && cert.domain_validation_options&.first&.resource_record
      option = cert.domain_validation_options.first
      tenant_alias.update!(
        acm_dns_validation_cname_name: option.resource_record.name,
        acm_dns_validation_cname_value: option.resource_record.value
      )
    end

    case cert.status
    when "ISSUED"
      tenant_alias.update!(acm_cert_status: "issued")
      attach_cert_to_alb(tenant_alias.acm_certificate_arn)
    when "FAILED", "REVOKED", "INACTIVE"
      tenant_alias.update!(acm_cert_status: "failed")
    else
      # PENDING_VALIDATION or EXPIRED — keep polling
      if attempt < MAX_ATTEMPTS
        PollAcmCertificateJob.set(wait: 1.hour).perform_later(tenant_alias_id, attempt: attempt + 1)
      else
        Rails.logger.warn("ACM cert for TenantAlias #{tenant_alias_id} never issued after #{MAX_ATTEMPTS} attempts")
      end
    end
  rescue Aws::ACM::Errors::ServiceError => e
    Rails.logger.error("ACM poll failed for TenantAlias #{tenant_alias_id}: #{e.message}")
  end

  private

  def attach_cert_to_alb(cert_arn)
    listener_arn = ENV["ALB_LISTENER_ARN"]
    if listener_arn.blank?
      Rails.logger.info("ACM cert issued but ALB_LISTENER_ARN not configured — skipping ALB attachment")
      return
    end

    elb = Aws::ElasticLoadBalancingV2::Client.new(region: ENV.fetch("AWS_REGION", "us-east-1"))
    elb.add_listener_certificates(
      listener_arn: listener_arn,
      certificates: [{ certificate_arn: cert_arn }]
    )
    Rails.logger.info("ACM cert #{cert_arn} attached to ALB listener #{listener_arn}")
  rescue Aws::ElasticLoadBalancingV2::Errors::ServiceError => e
    Rails.logger.error("Failed to attach ACM cert to ALB: #{e.message}")
  end
end
