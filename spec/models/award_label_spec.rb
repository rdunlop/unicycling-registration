# == Schema Information
#
# Table name: award_labels
#
#  id               :integer          not null, primary key
#  bib_number       :integer
#  competition_name :string(255)
#  team_name        :string(255)
#  details          :string(255)
#  place            :integer
#  user_id          :integer
#  registrant_id    :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  competitor_name  :string(255)
#  category         :string(255)
#

require 'spec_helper'

describe AwardLabel do
  before(:each) do
    @al = FactoryGirl.build_stubbed(:award_label)
  end

  it "has a valid factory" do
    @al.valid?.should == true
  end

  it "must have a registrant" do
    @al.registrant_id = nil
    @al.valid?.should == false
  end

  it "must have a user" do
    @al.user_id = nil
    @al.valid?.should == false
  end

  it "must have a place" do
    @al.place = nil
    @al.valid?.should == false
  end

  it "must have a positive place" do
    @al.place = 0
    @al.valid?.should == false
  end
end

describe AwardLabel do
  before(:each) do
    @al = FactoryGirl.build_stubbed(:award_label)
  end
  describe "with a solo competitor" do
    before(:each) do
      @comp = FactoryGirl.build_stubbed(:event_competitor)
      allow(@comp).to receive_message_chain(:members, :count).and_return(1)
      allow(@comp).to receive_message_chain(:members, :size).and_return(1)
      allow(@comp).to receive_message_chain(:members, :empty?).and_return(false)
      allow(@comp).to receive(:result).and_return("Some Result")
      @reg = FactoryGirl.build_stubbed(:competitor)
      allow(@comp).to receive(:registrants).and_return([@reg])
      allow(@comp).to receive(:place).and_return(1)
      @al = AwardLabel.new
      @al.user = FactoryGirl.build_stubbed(:user)
      @al.populate_from_competitor(@comp, @reg)
    end
    it "Can create the awards label from a competitor" do
      @al.line_1.should == "#{@reg.first_name} #{@reg.last_name}"
      @al.valid?.should == true
    end

    it "displays both names if in a pair" do
      @reg2 = FactoryGirl.build_stubbed(:competitor, :first_name => "Bob", :last_name => "Smith")
      allow(@comp).to receive_message_chain(:members, :count).and_return(2)
      allow(@comp).to receive(:registrants).and_return([@reg, @reg2])

      @al.populate_from_competitor(@comp, @reg)
      @al.line_1.should == "#{@reg.first_name} #{@reg.last_name} & #{@reg2.first_name} #{@reg2.last_name}"
    end

    it "displays the event name as line 2 for freestyle events" do
      competition = @comp.competition
      competition.scoring_class = "Freestyle"
      competition.name = "Hello"
      ev = competition.event
      ev.name = "Individual"

      @al.populate_from_competitor(@comp, @reg)
      @al.line_2.should == "Individual"
    end

    it "displays the competition name as line 2 for distance events" do
      competition = @comp.competition
      competition.scoring_class = "Distance"
      competition.name = "10k Standard"
      ev = competition.event
      ev.name = "10k"

      @al.populate_from_competitor(@comp, @reg)
      @al.line_2.should == "10k Standard"
    end

    it "displays the team name as line 3" do
      @comp.custom_name = "Robin Team"
      @al.populate_from_competitor(@comp, @reg)
      @al.line_3.should == "Robin Team"
    end

    describe "when the competitor has expert results" do
      before(:each) do
        @comp.competition.scoring_class = "Distance"
        @comp.competition.has_age_groups = true
        allow(@comp).to receive(:overall_place).and_return(3)
      end

      it "uses the age group and the gender as line 4" do
        allow(@comp).to receive(:age_group_entry_description).and_return("This is the age group")
        @al.populate_from_competitor(@comp, @reg, false)
        @al.line_4.should == "This is the age group"
      end

      it "sets the age group to Expert Male when expert" do
        @al.populate_from_competitor(@comp, @reg, true)
        @al.line_4.should == "Expert Male"
      end
    end

    it "stores the competitor.result as details, and line 5" do
      @al.populate_from_competitor(@comp, @reg)
      @al.line_5.should == "Some Result"
    end

    it "sets the award place from the competitor" do
      allow(@comp).to receive(:place).and_return(2)
      @al.populate_from_competitor(@comp, @reg)
      @al.place.should == 2
    end

    it "translates from places to line6" do
      @al.place = 1
      @al.line_6.should == "1st Place"
      @al.place = 2
      @al.line_6.should == "2nd Place"
      @al.place = 3
      @al.line_6.should == "3rd Place"
      @al.place = 4
      @al.line_6.should == "4th Place"
      @al.place = 5
      @al.line_6.should == "5th Place"
      @al.place = 6
      @al.line_6.should == "6th Place"
    end
  end
end
