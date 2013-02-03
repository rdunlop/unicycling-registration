require "spec_helper"

describe Notifications do
  before(:each) do
    @ec = FactoryGirl.create(:event_configuration, :long_name => "NAUCC 2140")
  end
  describe "ipn_received" do
    let(:mail) { Notifications.ipn_received("something") }

    it "renders the headers" do
      mail.subject.should eq("Ipn received")
      mail.to.should eq([@ec.contact_email])
      mail.from.should eq(["from@example.com"])
    end

    it "renders the body" do
      mail.body.encoded.should match("something")
    end
  end

  describe "payment_completed" do
    let(:payment) { FactoryGirl.create(:payment) }
    let!(:payment_detail) { FactoryGirl.create(:payment_detail, :amount => 10, :payment => payment) }
    let(:mail) { Notifications.payment_completed(payment) }

    it "renders the headers" do
      mail.subject.should eq("Payment completed")
      mail.to.should eq([payment.user.email])
      mail.bcc.should eq([@ec.contact_email])
      mail.from.should eq(["from@example.com"])
    end

    it "assigns the total_amount" do
      mail.body.should match(/A payment for 10.00 has been received/)
    end
    it "assigns the full-event-name to @event_name" do
      mail.body.should match(/NAUCC 2140 - Payment Received/)
    end
  end

end
