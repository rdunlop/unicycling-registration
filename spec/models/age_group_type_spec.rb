require 'spec_helper'

describe AgeGroupType do
  it "must have a name" do
    agt = AgeGroupType.new
    agt.valid?.should == false
    agt.name = "Default"
    agt.valid?.should == true
  end
end
