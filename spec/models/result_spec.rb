# == Schema Information
#
# Table name: results
#
#  id             :integer          not null, primary key
#  competitor_id  :integer
#  result_type    :string(255)
#  result_subtype :integer
#  place          :integer
#  status         :string(255)
#  created_at     :datetime
#  updated_at     :datetime
#
# Indexes
#
#  index_results_on_competitor_id_and_result_type  (competitor_id,result_type) UNIQUE
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
