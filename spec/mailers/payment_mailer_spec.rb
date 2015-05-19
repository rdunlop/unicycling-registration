require "spec_helper"

describe PaymentMailer do
  before(:each) do
    @ec = FactoryGirl.create(:event_configuration, :long_name => "NAUCC 2140")
  end
  describe "ipn_received" do
    let(:mail) { PaymentMailer.ipn_received("something") }

    it "renders the headers" do
      Rails.application.secrets.error_emails = ["robin+e@dunlopweb.com"]
      expect(mail.subject).to eq("Ipn received")
      expect(mail.to).to eq(["robin+e@dunlopweb.com"])
      expect(mail.from).to eq(["from@example.com"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("something")
    end
  end

  describe "payment_completed" do
    let(:payment) { FactoryGirl.create(:payment, :completed => true) }
    let!(:payment_detail) { FactoryGirl.create(:payment_detail, :amount => 10, :payment => payment) }
    before(:each) do
      payment.reload
      Rails.application.secrets.payment_notice_email = "robin+p@dunlopweb.com"
      @mail = PaymentMailer.payment_completed(payment)
    end

    it "renders the headers" do
      expect(@mail.subject).to eq("Payment Completed")
      expect(@mail.to).to eq([payment.user.email])
      expect(@mail.bcc).to eq(["robin+p@dunlopweb.com"])
      expect(@mail.from).to eq(["from@example.com"])
    end

    it "assigns the total_amount" do
      expect(@mail.body).to match(/A payment for \$10.00 USD has been received/)
    end
    it "assigns the full-event-name to @event_name" do
      expect(@mail.body).to match(/NAUCC 2140 - Payment Received/)
    end
  end
end
