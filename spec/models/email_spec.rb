require 'spec_helper'

describe Email do
  before(:each) do
    @email = FactoryGirl.build(:email)
  end
  it "is initially valid" do
    expect(@email.valid?).to eq(true)
  end
  it "must have a subject" do
    @email.subject = nil
    expect(@email.valid?).to eq(false)
  end
end
