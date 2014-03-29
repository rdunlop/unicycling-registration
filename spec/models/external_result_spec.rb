# == Schema Information
#
# Table name: external_results
#
#  id            :integer          not null, primary key
#  competitor_id :integer
#  details       :string(255)
#  rank          :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
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

  it "must have a rank" do
    @er.rank = nil
    @er.valid?.should == false
  end
end
