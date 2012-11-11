require 'spec_helper'

describe EventChoice do
  before(:each) do
    @event = FactoryGirl.create(:event)
    @ec = FactoryGirl.create(:event_choice, :event => @event)
  end
  it "is valid from FactoryGirl" do
    @ec.valid?.should == true
  end

  it "requires a export_name" do
    @ec.export_name = nil
    @ec.valid?.should == false
  end
  it "export name must be unique" do
    @ec2 = FactoryGirl.build(:event_choice, :export_name => @ec.export_name)
    @ec2.valid?.should == false
  end

  it "has an event" do
    @ec.event.should == @event
  end

  it "must have a cell_type" do
    @ec.cell_type = nil
    @ec.valid?.should == false
  end

  it "can have an cell_type of boolean" do
    @ec.cell_type = "boolean"
    @ec.valid?.should == true
  end

  it "can have a cell_type of text" do
    @ec.cell_type = "text"
    @ec.valid?.should == true
  end

  it "cannot have an arbitrary cell_type" do
    @ec.cell_type = "robin"
    @ec.valid?.should == false
  end

  it "has a choicename" do
    @ec.choicename.should == "choice#{@ec.id}"
  end
end
