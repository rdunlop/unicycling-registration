# == Schema Information
#
# Table name: competitions
#
#  id                    :integer          not null, primary key
#  event_id              :integer
#  name                  :string(255)
#  locked                :boolean
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  age_group_type_id     :integer
#  has_experts           :boolean          default(FALSE)
#  has_age_groups        :boolean          default(FALSE)
#  scoring_class         :string(255)
#  start_data_type       :string(255)
#  end_data_type         :string(255)
#  uses_lane_assignments :boolean          default(FALSE)
#

require 'spec_helper'

describe Competition do
  before(:each) do
    @ev = FactoryGirl.create(:event)
    @ec = FactoryGirl.create(:competition, :event => @ev)
  end
  it "is valid from FactoryGirl" do
    @ec.valid?.should == true
  end

  it "allows a start_data_type" do
    @ec.start_data_type = "Single Attempt"
    @ec.valid?.should == true
  end

  it "allows blank start_data_type" do
    @ec.start_data_type = nil
    @ec.should be_valid
    @ec.start_data_type = ""
    @ec.should be_valid
  end

  it "requires an event" do
    @ec.event = nil
    @ec.valid?.should == false
  end

  it "requires a name" do
    @ec.name = nil
    @ec.valid?.should == false
  end
  describe "the scoring_class" do
    it "cannot be blank" do
      @ec.scoring_class = nil
      @ec.valid?.should == false
    end
    it "can be Freestyle" do
      @ec.scoring_class = "Freestyle"
      @ec.valid?.should == true
    end
    it "can be Flatland" do
      @ec.scoring_class = "Flatland"
      @ec.valid?.should == true
    end
    it "can be Street" do
      @ec.scoring_class = "Street"
      @ec.valid?.should == true
    end
    it "can be High/Long" do
      @ec.scoring_class = "High/Long"
      @ec.age_group_type = FactoryGirl.build_stubbed(:age_group_type)
      @ec.valid?.should == true
    end

    it "can be overall Champion" do
      @ec.scoring_class = "Overall Champion"
      expect(@ec).to be_invalid
      @ec.combined_competition = FactoryGirl.create(:combined_competition)
      expect(@ec).to be_valid
    end
  end

  it "is not_expert by default" do
    comp = Competition.new
    comp.has_experts.should == false
  end

  describe "with a user" do
    before(:each) do
      @user = FactoryGirl.create(:user)
    end
    it "says there are no judges" do
      @ec.has_judge(@user).should == false
      @ec.get_judge(@user).should == nil
    end

    describe "as a judge" do
      before(:each) do
        @judge = FactoryGirl.create(:judge, :competition => @ec, :user => @user)
      end

      it "has judge" do
        @ec.has_judge(@user).should == true
        @ec.get_judge(@user).should == @judge
      end
    end
  end

  it "Cannot be published until it is locked" do
    @ec.locked = false
    @ec.published = true
    expect(@ec).to be_invalid
  end

  it "Cannot be awarded until it is published" do
    @ec.locked = true
    @ec.published = false
    @ec.awarded = true
    expect(@ec).to be_invalid
  end

  it "can create a competitor from registrants" do
    regs = [FactoryGirl.create(:competitor),
      FactoryGirl.create(:competitor),
      FactoryGirl.create(:competitor)]
    @ec.create_competitor_from_registrants(regs, "Robin's Team")
    comp = Competitor.last
    comp.members.count.should == 3
    comp.name.should == "Robin's Team"
  end

  it "has an event" do
    @ec.event.should == @ev
  end

  it "uses the event name in its name" do
    @ec.to_s.should == @ec.name
  end

  it "doesn't allow automatic competitor creation with multi-reg competitions" do
    expect(@ec).to be_valid
    @ec.num_members_per_competitor = "Two"
    expect(@ec).to be_valid
    @ec.automatic_competitor_creation = true
    expect(@ec).to be_invalid
    @ec.num_members_per_competitor = "One"
    expect(@ec).to be_valid
  end
end
