require "spec_helper"

describe Notifications do
  describe "ipn_received" do
    let(:mail) { Notifications.ipn_received("something") }

    it "renders the headers" do
      mail.subject.should eq("Ipn received")
      mail.to.should eq(["robin@dunlopweb.com"])
      mail.from.should eq(["from@example.com"])
    end

    it "renders the body" do
      mail.body.encoded.should match("something")
    end
  end

  describe "payment_completed" do
    let(:payment) { FactoryGirl.create(:payment) }
    let(:mail) { Notifications.payment_completed(payment) }

    it "renders the headers" do
      mail.subject.should eq("Payment completed")
      mail.to.should eq(["robin@dunlopweb.com"])
      mail.from.should eq(["from@example.com"])
    end

    it "renders the body" do
      mail.body.encoded.should match("Payment Completed")
    end
  end

end
