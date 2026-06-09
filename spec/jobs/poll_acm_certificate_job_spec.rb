require "spec_helper"

RSpec.describe PollAcmCertificateJob, sidekiq: :fake do
  let(:tenant) { FactoryBot.create(:tenant, subdomain: "testorg") }
  let(:cert_arn) { "arn:aws:acm:us-east-1:123456789:certificate/abc-123" }
  let(:listener_arn) { "arn:aws:elasticloadbalancing:us-east-1:123456789:listener/app/my-alb/abc/xyz" }

  let(:tenant_alias) do
    FactoryBot.create(:tenant_alias,
                      tenant: tenant,
                      website_alias: "reg.example.com",
                      acm_certificate_arn: cert_arn,
                      acm_cert_status: "pending",
                      acm_dns_validation_cname_name: "_abc.reg.example.com.",
                      acm_dns_validation_cname_value: "_xyz.acm.amazon.com.")
  end

  let(:acm_client) { instance_double(Aws::ACM::Client) }
  let(:elb_client) { instance_double(Aws::ElasticLoadBalancingV2::Client) }

  before do
    allow(Aws::ACM::Client).to receive(:new).and_return(acm_client)
    allow(Aws::ElasticLoadBalancingV2::Client).to receive(:new).and_return(elb_client)
    allow(acm_client).to receive(:describe_certificate)
    allow(elb_client).to receive(:add_listener_certificates)
  end

  def acm_response(status)
    double(certificate: double(
      status: status,
      domain_validation_options: [
        double(resource_record: double(
          name: "_abc.reg.example.com.",
          value: "_xyz.acm.amazon.com."
        ))
      ]
    ))
  end

  describe "#perform" do
    context "when cert is ISSUED" do
      before do
        allow(acm_client).to receive(:describe_certificate)
          .with(certificate_arn: cert_arn)
          .and_return(acm_response("ISSUED"))
      end

      it "marks status as issued" do
        described_class.new.perform(tenant_alias.id)

        expect(tenant_alias.reload.acm_cert_status).to eq("issued")
      end

      it "attaches cert to ALB when ALB_LISTENER_ARN is set" do
        allow(ENV).to receive(:[]).and_call_original
        allow(ENV).to receive(:[]).with("ALB_LISTENER_ARN").and_return(listener_arn)

        described_class.new.perform(tenant_alias.id)

        expect(elb_client).to have_received(:add_listener_certificates).with(
          listener_arn: listener_arn,
          certificates: [{ certificate_arn: cert_arn }]
        )
      end

      it "skips ALB attachment when ALB_LISTENER_ARN is not set" do
        allow(ENV).to receive(:[]).and_call_original
        allow(ENV).to receive(:[]).with("ALB_LISTENER_ARN").and_return(nil)

        described_class.new.perform(tenant_alias.id)

        expect(elb_client).not_to have_received(:add_listener_certificates)
      end
    end

    context "when cert is FAILED" do
      before do
        allow(acm_client).to receive(:describe_certificate)
          .with(certificate_arn: cert_arn)
          .and_return(acm_response("FAILED"))
      end

      it "marks status as failed" do
        described_class.new.perform(tenant_alias.id)

        expect(tenant_alias.reload.acm_cert_status).to eq("failed")
      end
    end

    context "when cert is still PENDING_VALIDATION" do
      before do
        allow(acm_client).to receive(:describe_certificate)
          .with(certificate_arn: cert_arn)
          .and_return(acm_response("PENDING_VALIDATION"))
      end

      it "re-enqueues itself with a 1-hour delay" do
        requeue_double = double(perform_later: nil)
        allow(described_class).to receive(:set).with(wait: 1.hour).and_return(requeue_double)

        described_class.new.perform(tenant_alias.id, attempt: 1)

        expect(described_class).to have_received(:set).with(wait: 1.hour)
      end

      it "does not re-enqueue after MAX_ATTEMPTS" do
        allow(described_class).to receive(:set)

        described_class.new.perform(tenant_alias.id, attempt: PollAcmCertificateJob::MAX_ATTEMPTS)

        expect(described_class).not_to have_received(:set)
      end
    end

    it "does nothing if tenant alias no longer exists" do
      described_class.new.perform(99_999)

      expect(acm_client).not_to have_received(:describe_certificate)
    end

    it "does nothing if cert is already issued on the record" do
      tenant_alias.update!(acm_cert_status: "issued")

      described_class.new.perform(tenant_alias.id)

      expect(acm_client).not_to have_received(:describe_certificate)
    end
  end
end
