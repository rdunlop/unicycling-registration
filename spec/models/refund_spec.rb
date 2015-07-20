# == Schema Information
#
# Table name: refunds
#
#  id          :integer          not null, primary key
#  user_id     :integer
#  refund_date :datetime
#  note        :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#  percentage  :integer          default(100)
#
# Indexes
#
#  index_refunds_on_user_id  (user_id)
#

require 'spec_helper'

describe Refund do
  before(:each) do
    @refund = FactoryGirl.create(:refund)
  end

  it "should have 100% refund" do
    expect(@refund.percentage).to eq(100)
  end

  it "creates a valid from factoryGirl" do
    expect(@refund.valid?).to eq(true)
  end

  it "requires a user" do
    @refund.user = nil
    expect(@refund.valid?).to eq(false)
  end

  it "requires a note" do
    @refund.note = nil
    expect(@refund.valid?).to eq(false)
    @refund.note = ""
    expect(@refund.valid?).to eq(false)
  end
end
