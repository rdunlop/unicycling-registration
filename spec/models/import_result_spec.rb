require 'spec_helper'

describe ImportResult do
  before(:each) do
    @ir = FactoryGirl.create(:import_result)
  end
  it "has a valid factory" do
    @ir.valid?.should == true
  end

  it "requires a raw_data" do
    @ir.raw_data = nil
    @ir.valid?.should == false
  end

  it "requires a user" do
    @ir.user_id = nil
    @ir.valid?.should == false
  end

  it "requires a competition" do
    @ir.competition_id = nil
    @ir.valid?.should == false
  end

end
