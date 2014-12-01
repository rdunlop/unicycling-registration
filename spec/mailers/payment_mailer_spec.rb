require "spec_helper"

describe PaymentMailer do
  before(:each) do
    @ec = FactoryGirl.create(:event_configuration, :long_name => "NAUCC 2140")
  end
  describe "ipn_received" do
    let(:mail) { PaymentMailer.ipn_received("something") }

    it "renders the headers" do
      Rails.application.secrets.error_emails = ["robin+e@dunlopweb.com"]
      mail.subject.should eq("Ipn received")
      mail.to.should eq(["robin+e@dunlopweb.com"])
      mail.from.should eq(["from@example.com"])
    end

    it "renders the body" do
      mail.body.encoded.should match("something")
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
      @mail.subject.should eq("Payment completed")
      @mail.to.should eq([payment.user.email])
      @mail.bcc.should eq(["robin+p@dunlopweb.com"])
      @mail.from.should eq(["from@example.com"])
    end

    it "assigns the total_amount" do
      @mail.body.should match(/A payment for \$10.00 USD has been received/)
    end
    it "assigns the full-event-name to @event_name" do
      @mail.body.should match(/NAUCC 2140 - Payment Received/)
    end
  end
end
