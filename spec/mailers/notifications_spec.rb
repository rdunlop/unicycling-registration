require "spec_helper"

describe Notifications do
  before(:each) do
    @tenant = FactoryGirl.create(:tenant, :test_schema)
    @ec = FactoryGirl.create(:event_configuration, long_name: "NAUCC 2140", contact_email: "guy@convention.com")
  end

  describe "request_registrant_access" do
    let(:mail) do
      Notifications.request_registrant_access(FactoryGirl.create(:registrant, first_name: "Billy", last_name: "Johnson"),
                                              FactoryGirl.create(:user, email: "james@dean.com"))
    end
    it "identifies the person making the request" do
      expect(mail.body).to match(/james@dean.com has requested permission to view the registration record of Billy Johnson/)
    end
  end

  describe "registrant_access_accepted" do
    let(:mail) do
      Notifications.registrant_access_accepted(FactoryGirl.create(:registrant, first_name: "Billy", last_name: "Johnson"),
                                               FactoryGirl.create(:user, email: "james@dean.com"))
    end
    it "identifies the accetance of the request" do
      expect(mail.body).to match(/Your request for access to the registration of Billy Johnson has been accepted/)
    end
  end

  describe "send_feedback" do
    let(:contact_form) { ContactForm.new(feedback: "This is some feedback", email: "test@complaint.com") }
    let(:mail) do
      Notifications.send_feedback(contact_form.serialize)
    end

    it "sets the reply-to address" do
      expect(mail.reply_to).to match(["test@complaint.com"])
    end

    it "sends the email to the event_configuration contact person" do
      expect(mail.to).to match(["guy@convention.com"])
    end

    it "sets the exception emailer targets as CC" do
      expect(mail.cc).to match(["robin+e@dunlopweb.com"])
    end

    describe "with a signed in user without specifying an e-mail" do
      let(:contact_form) { ContactForm.new(feedback: "other feedback", username: "test@email.com") }

      it "sets the reply to address" do
        expect(mail.reply_to).to match(["test@email.com"])
      end
    end
  end
end
