# == Schema Information
#
# Table name: event_choices
#
#  id                          :integer          not null, primary key
#  event_id                    :integer
#  cell_type                   :string(255)
#  multiple_values             :string(255)
#  position                    :integer
#  created_at                  :datetime
#  updated_at                  :datetime
#  optional                    :boolean          default(FALSE), not null
#  optional_if_event_choice_id :integer
#  required_if_event_choice_id :integer
#

require 'spec_helper'

describe EventChoice do
  before(:each) do
    @event = FactoryGirl.create(:event)
    @ec = FactoryGirl.create(:event_choice, event: @event)
  end
  it "is valid from FactoryGirl" do
    expect(@ec.valid?).to eq(true)
  end

  it "requires a label" do
    @ec.label = nil
    expect(@ec.valid?).to eq(false)
  end

  it "can have an empty tooltip" do
    @ec.tooltip = ""
    expect(@ec.valid?).to eq(true)
    expect(@ec.tooltip.blank? ? true : false ).to eq(true)
  end

  it "must have a value for optional" do
    @ec.optional = nil
    expect(@ec.valid?).to eq(false)
  end

  it "allows nil for optional_if_event_choice" do
    @ec.optional_if_event_choice = nil
    expect(@ec.valid?).to eq(true)
  end

  it "allows nil for required_if_event_choice" do
    @ec.required_if_event_choice = nil
    expect(@ec.valid?).to eq(true)
  end

  it "defaults optional_if_event_choice to nil" do
    ec = EventChoice.new
    expect(ec.optional_if_event_choice).to be_nil
  end

  it "defaults required_if_event_choice to nil" do
    ec = EventChoice.new
    expect(ec.required_if_event_choice).to be_nil
  end

  it "has an event" do
    expect(@ec.event).to eq(@event)
  end

  it "must have a cell_type" do
    @ec.cell_type = nil
    expect(@ec.valid?).to eq(false)
  end

  it "can have an cell_type of boolean" do
    @ec.cell_type = "boolean"
    expect(@ec.valid?).to eq(true)
  end

  it "can have a cell_type of text" do
    @ec.cell_type = "text"
    expect(@ec.valid?).to eq(true)
  end

  it "can have a cell_type of 'multiple'" do
    @ec.cell_type = "multiple"
    expect(@ec.valid?).to eq(true)
  end

  it "cannot have an arbitrary cell_type" do
    @ec.cell_type = "robin"
    expect(@ec.valid?).to eq(false)
  end

  it "has a choicename" do
    expect(@ec.choicename).to eq("choice#{@ec.id}")
  end

  it "has a to_s" do
    expect(@ec.to_s).to eq(@ec.event.to_s + " - " + @ec.label)
  end

  describe "when parsing the multiple_values" do
    it "can parse single value" do
      @ec.multiple_values = "one"
      expect(@ec.values).to eq(["one"])
    end
    it "can parse 2 values" do
      @ec.multiple_values = "one, two"
      expect(@ec.values).to eq(["one", "two"])
    end
  end

  describe "with associated registrant_choice" do
    before(:each) do
      @rc = FactoryGirl.create(:registrant_choice, event_choice: @ec)
    end
    it "deletes the RC when deleted" do
      expect(RegistrantChoice.all.count).to eq(1)
      @ec.destroy
      expect(RegistrantChoice.all.count).to eq(0)
    end

    it "lists unique event_choice values" do
      expect(@ec.unique_values).to eq([@rc.value])
    end
  end

  it "can have the same position but in different events" do
    @ev = FactoryGirl.create(:event)
    @ev2 = FactoryGirl.create(:event)
    ec1 = FactoryGirl.create(:event_choice, event: @ev)
    ec2 = FactoryGirl.create(:event_choice, event: @ev2)
    expect(ec1.position).to eq(ec2.position)
    expect(ec2.valid?).to eq(true)
  end
end
