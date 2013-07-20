require 'spec_helper'

describe Member do
  it "must have a competitor and registrant" do
    member = Member.new

    member.valid?.should == false

    member.competitor = FactoryGirl.create(:event_competitor)

    member.valid?.should == false

    member.registrant = FactoryGirl.create(:registrant)

    member.valid?.should == true
  end
end
