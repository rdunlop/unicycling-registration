require "spec_helper"

RSpec.describe RequestAcmCertificateJob, sidekiq: :fake do
  let(:tenant) { FactoryBot.create(:tenant, subdomain: "testorg") }
  let(:tenant_alias) { FactoryBot.create(:tenant_alias, tenant: tenant, website_alias: "reg.example.com") }

  describe "#perform" do
    let(:acm_client) { instance_double(Aws::ACM::Client) }
    let(:cert_arn) { "arn:aws:acm:us-east-1:123456789:certificate/abc-123" }

    let(:validation_option) do
      double(resource_record: double(name: "_abc.reg.example.com.", value: "_xyz.acm.amazon.com."))
    end

    let(:describe_response) do
      double(certificate: double(
        domain_validation_options: [validation_option]
      ))
    end

    let(:poll_job_double) { double(perform_later: nil) }

    before do
      allow(Aws::ACM::Client).to receive(:new).and_return(acm_client)
      allow(acm_client).to receive(:request_certificate)
        .and_return(double(certificate_arn: cert_arn))
      allow(acm_client).to receive(:describe_certificate)
        .with(certificate_arn: cert_arn)
        .and_return(describe_response)
      allow(PollAcmCertificateJob).to receive(:set).and_return(poll_job_double)
    end

    it "requests a certificate and saves the ARN and CNAME validation record" do
      described_class.new.perform(tenant_alias.id)

      tenant_alias.reload
      expect(tenant_alias.acm_certificate_arn).to eq(cert_arn)
      expect(tenant_alias.acm_cert_status).to eq("pending")
      expect(tenant_alias.acm_dns_validation_cname_name).to eq("_abc.reg.example.com.")
      expect(tenant_alias.acm_dns_validation_cname_value).to eq("_xyz.acm.amazon.com.")
    end

    it "enqueues PollAcmCertificateJob after requesting the certificate" do
      poll_double = double(perform_later: nil)
      allow(PollAcmCertificateJob).to receive(:set).with(wait: 5.minutes).and_return(poll_double)

      described_class.new.perform(tenant_alias.id)

      expect(PollAcmCertificateJob).to have_received(:set).with(wait: 5.minutes)
    end

    it "does nothing if the tenant alias no longer exists" do
      described_class.new.perform(99_999)

      expect(acm_client).not_to have_received(:request_certificate)
    end

    it "does nothing if the cert is already issued" do
      tenant_alias.update!(acm_cert_status: "issued", acm_certificate_arn: cert_arn)

      described_class.new.perform(tenant_alias.id)

      expect(acm_client).not_to have_received(:request_certificate)
    end

    it "marks status as failed on AWS error" do
      allow(acm_client).to receive(:request_certificate)
        .and_raise(Aws::ACM::Errors::ServiceError.new(nil, "throttled"))

      described_class.new.perform(tenant_alias.id)

      expect(tenant_alias.reload.acm_cert_status).to eq("failed")
    end
  end
end
