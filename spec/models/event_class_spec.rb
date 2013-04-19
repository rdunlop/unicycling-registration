require 'spec_helper'

describe EventClass do
    it "must have a name" do
        ec = EventClass.new
        ec.valid?.should == false
        ec.name = "Freestyle"
        ec.valid?.should == true
    end
end
