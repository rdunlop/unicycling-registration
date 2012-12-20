require 'spec_helper'

describe ExpenseGroup do
  before(:each) do
    @group = FactoryGirl.create(:expense_group)
  end
  it "can be created by the factory" do
    @group.valid?.should == true
  end
  it "must have a name" do
    @group.group_name = nil
    @group.valid?.should == false
  end
  it "must have a visible setting of true or false" do
    @group.visible = nil
    @group.valid?.should == false

    @group.visible = true
    @group.valid?.should == true
  end
  it "should have a nice to_s" do
    @group.to_s.should == @group.group_name
  end
end
