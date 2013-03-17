require 'spec_helper'

describe Event do
  before(:each) do
    @ev = FactoryGirl.create(:event)
  end
  it "is valid from FactoryGirl" do
    @ev.valid?.should == true
  end

  it "requires a category" do
    @ev.category = nil
    @ev.valid?.should == false
  end

  it "should have name as to_s" do
    @ev.to_s.should == @ev.name
  end

  it "describes itself as StandardSkill if named so" do
    @ev.standard_skill?.should == false
    choice = @ev.primary_choice
    choice.label = "Standard Skill"
    choice.save
    @ev.standard_skill?.should == true
  end

  it "has many event_choices" do
    @ec = FactoryGirl.create(:event_choice, :event => @ev)
    @ev.event_choices = [@ec]
  end

  it "sorts event choices by position" do
    @ec4 = FactoryGirl.create(:event_choice, :event => @ev, :position => 4)
    @ec2 = FactoryGirl.create(:event_choice, :event => @ev, :position => 2)
    @ec3 = FactoryGirl.create(:event_choice, :event => @ev, :position => 3)

    @ev.event_choices.should == [@ev.primary_choice, @ec2, @ec3, @ec4]
  end
  it "destroys associated event_choices upon destroy" do
    EventChoice.all.count.should == 1
    @ev.destroy
    EventChoice.all.count.should == 0
  end

  it "creates an associated event_choice automatically" do
    @ev.event_choices.count.should == 1
    @choice = @ev.event_choices.first
    @choice.cell_type.should == 'boolean'
    @choice.position.should == 1
    @choice.export_name.should == "new_event_yn"
  end

  it "has many event_categories" do
    @ecat1 = FactoryGirl.create(:event_category, :event => @ev, :position => 1)
    @ecat2 = FactoryGirl.create(:event_category, :event => @ev, :name => "Other", :position => 2)
    @ev.event_categories.should == [@ecat1, @ecat2]
  end

  it "has a primary_choice" do
    @ev.primary_choice.should == @ev.event_choices.first
  end

  describe "when a user has chosen an event" do
    before(:each) do
      @reg_choice = FactoryGirl.create(:registrant_choice)
      @ev = @reg_choice.event_choice.event
      @ec = FactoryGirl.create(:registrant_choice, :registrant => @reg_choice.registrant, :event_choice => @ev.primary_choice, :value => "1")
    end

    it "will know that it is selected" do
      @ev.num_competitors.should == 1
    end
    it "will not count entries which are not selected" do
      @ec.value = "0"
      @ec.save
      @ev.num_competitors.should == 0
    end
    it "will not count if no one has selected the choice" do
      event = FactoryGirl.create(:event)
      event.num_competitors.should == 0
    end
  end
end
