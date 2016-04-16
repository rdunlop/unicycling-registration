require 'spec_helper'

describe Feedback do
  let(:feedback) { described_class.new }

  it "is not valid without feedback" do
    feedback.entered_email = "robin@dunlopweb.com"
    expect(feedback).not_to be_valid
    feedback.message = "hi"
    expect(feedback).to be_valid
  end

  it "is not valid without mail" do
    feedback.message = "hi"
    expect(feedback).not_to be_valid
    feedback.entered_email = "robin@dunlopweb.com"
    expect(feedback).to be_valid
  end

  it "returns a default username" do
    expect(feedback.username).to eq("not-signed-in")
  end

  it "can overwrite the username" do
    feedback.user = FactoryGirl.create(:user)
    expect(feedback.username).to eq(feedback.user.email)
  end

  it "doensn't need to specify e-mail when signed in" do
    user = FactoryGirl.create(:user)
    feedback.user = user
    feedback.message = "This is a great site"
    expect(feedback).to be_valid
  end

  it "has default registrants" do
    expect(feedback.user_first_registrant_name).to eq("unknown")
  end

  it "can overwrite registrants" do
    registrant = FactoryGirl.create(:registrant)
    feedback.user = registrant.user
    expect(feedback.user_first_registrant_name).to eq(registrant.name)
  end

  it "can be updated by a user object" do
    reg = FactoryGirl.create(:competitor, first_name: "Bob", last_name: "Smith")
    feedback.user = reg.user
    expect(feedback.username).to eq(reg.user.email)
    expect(feedback.user_first_registrant_name).to eq("Bob Smith")
  end

  it "returns the email if set for replyto" do
    feedback.entered_email = "robin@dunlopweb.com"
    expect(feedback.reply_to_email).to eq("robin@dunlopweb.com")
  end

  it "returns the username if the email is not set for replyto" do
    feedback.entered_email = ""
    user = FactoryGirl.create(:user, email: "bob@dunlopweb.com")
    feedback.user = user
    expect(feedback.reply_to_email).to eq("bob@dunlopweb.com")
  end
end

# == Schema Information
#
# Table name: feedbacks
#
#  id             :integer          not null, primary key
#  user_id        :integer
#  entered_email  :string
#  message        :text
#  status         :string           default("new"), not null
#  resolved_at    :datetime
#  resolved_by_id :integer
#  resolution     :text
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
