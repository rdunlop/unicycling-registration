require 'spec_helper'

describe FeedbacksHelper do
  let(:feedback) do
    FactoryGirl.create(:feedback,
                       message: "This is a really really long message, with lots
                       to say, and lots not to say")
  end

  it "shortens the message" do
    expect(helper.message_summary(feedback)).to eq("This is a really really long message, with...")
  end
end
