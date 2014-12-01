# == Schema Information
#
# Table name: event_choices
#
#  id                          :integer          not null, primary key
#  event_id                    :integer
#  export_name                 :string(255)
#  cell_type                   :string(255)
#  multiple_values             :string(255)
#  label                       :string(255)
#  position                    :integer
#  created_at                  :datetime
#  updated_at                  :datetime
#  autocomplete                :boolean
#  optional                    :boolean          default(FALSE)
#  tooltip                     :string(255)
#  optional_if_event_choice_id :integer
#  required_if_event_choice_id :integer
#
# Indexes
#
#  index_event_choices_on_event_id_and_position  (event_id,position) UNIQUE
#  index_event_choices_on_export_name            (export_name) UNIQUE
#

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

  it "can have an empty tooltip" do
    @ec.tooltip = ""
    @ec.valid?.should == true
    (@ec.tooltip.blank? ? true : false ).should == true
  end

  it "requires a export_name" do
    @ec.export_name = nil
    @ec.valid?.should == false
  end
  it "export name must be unique" do
    @ec2 = FactoryGirl.build(:event_choice, :export_name => @ec.export_name)
    @ec2.valid?.should == false
  end

  it "must have a value for optional" do
    @ec.optional = nil
    @ec.valid?.should == false
  end

  it "allows nil for optional_if_event_choice" do
    @ec.optional_if_event_choice = nil
    @ec.valid?.should == true
  end

  it "allows nil for required_if_event_choice" do
    @ec.required_if_event_choice = nil
    @ec.valid?.should == true
  end

  it "defaults optional_if_event_choice to nil" do
    ec = EventChoice.new
    ec.optional_if_event_choice.should == nil
  end

  it "defaults required_if_event_choice to nil" do
    ec = EventChoice.new
    ec.required_if_event_choice.should == nil
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
    @ec.to_s.should == @ec.event.to_s + " - " + @ec.label
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

  it "cannot have duplicate positions" do
    @ev = FactoryGirl.create(:event)
    FactoryGirl.create(:event_choice, :event => @ev, :position => 1)
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
