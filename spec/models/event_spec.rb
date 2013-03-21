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

  it "requires a name" do
    @ev.name = nil
    @ev.valid?.should == false
  end

  it "should have name as to_s" do
    @ev.to_s.should == @ev.name
  end

  it "describes itself as StandardSkill if named so" do
    @ev.standard_skill?.should == false
    @ev.name = "Standard Skill"
    @ev.save!
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

    @ev.event_choices.should == [@ec2, @ec3, @ec4]
  end
  it "destroys associated event_choices upon destroy" do
    FactoryGirl.create(:event_choice, :event => @ev)
    expect {
      @ev.destroy
    }.to change(EventChoice, :count).by(-1)
  end

  it "destroys associated event_categories upon destroy" do
    expect {
      @ev.destroy
    }.to change(EventCategory, :count).by(-1)
  end

  it "creates an associated event_category automatically" do
    @ev.event_categories.count.should == 1
    @category = @ev.event_categories.first
    @category.name.should == 'All'
    @category.position.should == 1
  end

  it "has many event_categories" do
    @ecat1 = @ev.event_categories.first
    @ecat2 = FactoryGirl.create(:event_category, :event => @ev, :name => "Other", :position => 2)
    @ev.event_categories.should == [@ecat1, @ecat2]
  end

  describe "when a user has chosen an event" do
    before(:each) do
      @ev = FactoryGirl.create(:event)
      @ec = FactoryGirl.create(:registrant_event_sign_up, :event => @ev, :event_category =>@ev.event_categories.first, :signed_up => true)
    end

    it "will know that it is selected" do
      @ev.num_competitors.should == 1
    end
    it "will not count entries which are not selected" do
      @ec.signed_up = false
      @ec.save
      @ev.num_competitors.should == 0
    end
    it "will not count if no one has selected the choice" do
      event = FactoryGirl.create(:event)
      event.num_competitors.should == 0
    end
  end
end
