# == Schema Information
#
# Table name: external_results
#
#  id            :integer          not null, primary key
#  competitor_id :integer
#  details       :string(255)
#  points        :decimal(6, 3)    not null
#  created_at    :datetime
#  updated_at    :datetime
#
# Indexes
#
#  index_external_results_on_competitor_id  (competitor_id)
#

require 'spec_helper'

describe ExternalResult do
  before(:each) do
    @er = FactoryGirl.create(:external_result)
  end
  it "has a valid factory" do
    @er.valid?.should == true
  end

  it "must have a competitor" do
    @er.competitor = nil
    @er.valid?.should == false
  end

  it "optional to have details" do
    @er.details = nil
    @er.valid?.should == true
  end

  it "must have a value for points" do
    @er.points = nil
    @er.valid?.should == false
  end
end
