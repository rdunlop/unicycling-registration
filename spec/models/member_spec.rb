require 'spec_helper'

describe Member do
  it "must have a competitor and registrant" do
    member = Member.new

    member.valid?.should == false

    member.competitor = FactoryGirl.create(:event_competitor, :event_category => FactoryGirl.create(:event).event_categories.first)

    member.valid?.should == false

    member.registrant = FactoryGirl.create(:registrant)

    member.valid?.should == true
  end
end
