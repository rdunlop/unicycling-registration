require "spec_helper"

describe Notifications do
  before(:each) do
    @ec = FactoryGirl.create(:event_configuration, :long_name => "NAUCC 2140")
  end
  describe "ipn_received" do
    let(:mail) { Notifications.ipn_received("something") }

    it "renders the headers" do
      ENV['ERROR_EMAIL'] = "robin+e@dunlopweb.com"
      mail.subject.should eq("Ipn received")
      mail.to.should eq(["robin+e@dunlopweb.com"])
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
      ENV['PAYMENT_NOTICE_EMAIL'] = "robin+p@dunlopweb.com"
      mail.subject.should eq("Payment completed")
      mail.to.should eq([payment.user.email])
      mail.bcc.should eq(["robin+p@dunlopweb.com"])
      mail.from.should eq(["from@example.com"])
    end

    it "assigns the total_amount" do
      mail.body.should match(/A payment for \$10.00 USD has been received/)
    end
    it "assigns the full-event-name to @event_name" do
      mail.body.should match(/NAUCC 2140 - Payment Received/)
    end
  end

  describe "request_registrant_access" do
    let(:mail) { Notifications.request_registrant_access(FactoryGirl.create(:registrant, :first_name => "Billy", :last_name => "Johnson"),
                                                         FactoryGirl.create(:user, :email => "james@dean.com")) }
    it "identifies the person making the request" do
      mail.body.should match(/james@dean.com has requested permission to view the registration record of Billy Johnson/)
    end
  end

  describe "registrant_access_accepted" do
    let(:mail) { Notifications.registrant_access_accepted(FactoryGirl.create(:registrant, :first_name => "Billy", :last_name => "Johnson"),
                                                         FactoryGirl.create(:user, :email => "james@dean.com")) }
    it "identifies the accetance of the request" do
      mail.body.should match(/Your request for access to the registration of Billy Johnson has been accepted/)
    end
  end

end
