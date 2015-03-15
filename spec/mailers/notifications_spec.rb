require "spec_helper"

describe Notifications do
  before(:each) do
    @ec = FactoryGirl.create(:event_configuration, :long_name => "NAUCC 2140")
  end

  describe "request_registrant_access" do
    let(:mail) { 
      Notifications.request_registrant_access(FactoryGirl.create(:registrant, :first_name => "Billy", :last_name => "Johnson"),
                                              FactoryGirl.create(:user, :email => "james@dean.com"))
    }
    it "identifies the person making the request" do
      expect(mail.body).to match(/james@dean.com has requested permission to view the registration record of Billy Johnson/)
    end
  end

  describe "registrant_access_accepted" do
    let(:mail) { 
      Notifications.registrant_access_accepted(FactoryGirl.create(:registrant, :first_name => "Billy", :last_name => "Johnson"),
                                               FactoryGirl.create(:user, :email => "james@dean.com"))
    }
    it "identifies the accetance of the request" do
      expect(mail.body).to match(/Your request for access to the registration of Billy Johnson has been accepted/)
    end
  end

end
