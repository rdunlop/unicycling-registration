require 'spec_helper'

describe EventChoice do
  before(:each) do
    @event = FactoryGirl.create(:event)
    @ec = FactoryGirl.create(:event_choice, :event => @event, :position => 2)
  end
  it "is valid from FactoryGirl" do
    @ec.valid?.should == true
  end

  it "requires a label" do
    @ec.label = nil
    @ec.valid?.should == false
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

  it "can have a cell_type of 'multiple'" do
    @ec.cell_type = "multiple"
    @ec.valid?.should == true
  end

  it "can have a cell_type of 'category'" do
    @ec.cell_type = "category"
    @ec.valid?.should == true
  end

  it "cannot have an arbitrary cell_type" do
    @ec.cell_type = "robin"
    @ec.valid?.should == false
  end

  it "must have a autocomplete value" do
    @ec.autocomplete = nil
    @ec.valid?.should == false
  end

  it "has a choicename" do
    @ec.choicename.should == "choice#{@ec.id}"
  end

  it "has a to_s" do
    @ec.to_s.should == @ec.event.to_s + " - " + @ec.export_name
  end

  describe "when parsing the multiple_values" do
    it "can parse single value" do
      @ec.multiple_values = "one"
      @ec.values.should == ["one"]
    end
    it "can parse 2 values" do
      @ec.multiple_values = "one, two"
      @ec.values.should == ["one", "two"]
    end
  end

  describe "when parsing the category's values" do
    before(:each) do
      @cat2 = FactoryGirl.create(:event_category, :event => @event, :name => "zwei", :position => 2)
      @cat1 = FactoryGirl.create(:event_category, :event => @event, :name => "ein", :position => 1)
    end
    it "should return the categories in values" do
      @ec.cell_type = "category"
      @ec.save!
      @ec.values.should == ["ein", "zwei"]
    end
  end

  describe "with associated registrant_choice" do
    before(:each) do
      @rc = FactoryGirl.create(:registrant_choice, :event_choice => @ec)
    end
    it "deletes the RC when deleted" do
      RegistrantChoice.all.count.should == 1
      @ec.destroy
      RegistrantChoice.all.count.should == 0
    end

    it "lists unique event_choice values" do
      @ec.unique_values.should == [@rc.value]
    end
  end

  it "must be a boolean to be in position 1" do
    ec = @event.primary_choice
    ec.cell_type = "boolean"
    ec.position = 1
    ec.valid?.should == true
    ec.cell_type = "multiple"
    ec.valid?.should == false
    ec.cell_type = "text"
    ec.valid?.should == false
  end

  it "cannot have duplicate positions" do
    @ev = FactoryGirl.create(:event)
    @ec = @ev.event_choices.first
    ec2 = FactoryGirl.build(:event_choice, :event => @ev)
    ec2.position = 1
    ec2.valid?.should == false
  end
  it "can have the same position but in different events" do
    @ev = FactoryGirl.create(:event)
    @ev2 = FactoryGirl.create(:event)
    ec1 = FactoryGirl.create(:event_choice, :event => @ev, :position => 2)
    ec2 = FactoryGirl.build(:event_choice, :event => @ev2, :position => 2)
    ec2.valid?.should == true
  end

end
