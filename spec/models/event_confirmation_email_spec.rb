require 'spec_helper'

describe EventConfirmationEmail do
  describe "when sending multiple e-mails" do
    let!(:event_configuration) { FactoryBot.create(:event_configuration) }
    let(:event_confirmation_email) { FactoryBot.create(:event_confirmation_email, subject: "Email {{ID}} Main Subject") }
    let!(:registrant_1) { FactoryBot.create(:competitor) }
    let!(:registrant_2) { FactoryBot.create(:competitor) }

    it "creates multiple subjects" do
      expect(event_confirmation_email.subject_result(registrant_1)).to eq("Email #{registrant_1.bib_number} Main Subject")
      expect(event_confirmation_email.subject_result(registrant_2)).to eq("Email #{registrant_2.bib_number} Main Subject")
    end
  end
end
