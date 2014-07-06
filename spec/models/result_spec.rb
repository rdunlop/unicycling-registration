# == Schema Information
#
# Table name: event_categories
#
#  id              :integer          not null, primary key
#  event_id        :integer
#  position        :integer
#  name            :string(255)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  age_range_start :integer          default(0)
#  age_range_end   :integer          default(100)
#

require 'spec_helper'

describe Result do
  before(:each) do
    @result = FactoryGirl.create(:result)
  end
  it "is valid from FactoryGirl" do
    expect(@result).to be_valid
  end

  it "only allows a single result per result-type/competitor pair" do
    result2 = FactoryGirl.build(:result, competitor: @result.competitor, result_type: @result.result_type)
    expect(result2).to be_invalid
  end

  it "allows multiple results for the same competitor, with different result_types" do
    expect(@result.result_type).to eq("AgeGroup")
    result2_overall = FactoryGirl.build(:result, competitor: @result.competitor, result_type: "Overall")
    expect(result2_overall).to be_valid
  end
end
