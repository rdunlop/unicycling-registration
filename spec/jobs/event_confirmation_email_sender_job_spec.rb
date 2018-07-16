require "spec_helper"

RSpec.describe EventConfirmationEmailSenderJob do
  let!(:event_configuration) { FactoryBot.create(:event_configuration) }
  let(:email) { FactoryBot.create(:event_confirmation_email, subject: "Email {{ID}} Main Subject") }

  describe "#perform" do
    subject(:job) { described_class.new(email) }

    context "without any registrants" do
      it "does nothing" do
        job.perform_now
      end
    end

    context "With a registrant" do
      let!(:competitor) { FactoryBot.create(:competitor) }

      it "sends an e-mail" do
        ActionMailer::Base.deliveries.clear
        job.perform_now
        num_deliveries = ActionMailer::Base.deliveries.size
        expect(num_deliveries).to eq(1)
        expect(ActionMailer::Base.deliveries[0].subject).to eq("Email #{competitor.bib_number} Main Subject")
      end
    end
  end
end
