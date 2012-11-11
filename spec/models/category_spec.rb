require 'spec_helper'

describe Category do
  it "must have a name" do
    cat = Category.new
    cat.valid?.should == false
    cat.name = "Track"
    cat.valid?.should == true
  end

  it "has events" do
    cat = FactoryGirl.create(:category)
    ev = FactoryGirl.create(:event, :category => cat)
    cat.events.should == [ev]
  end

  it "displays its name as to_s" do
    cat = FactoryGirl.create(:category)
    cat.to_s.should == cat.name
  end
end
