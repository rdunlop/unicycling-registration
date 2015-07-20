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
#  created_at       :datetime
#  updated_at       :datetime
#  competitor_name  :string(255)
#  category         :string(255)
#
# Indexes
#
#  index_award_labels_on_user_id  (user_id)
#

require 'spec_helper'

describe AwardLabel do
  before(:each) do
    @al = FactoryGirl.build_stubbed(:award_label)
  end

  it "has a valid factory" do
    expect(@al.valid?).to eq(true)
  end

  it "must have a registrant" do
    @al.registrant_id = nil
    expect(@al.valid?).to eq(false)
  end

  it "must have a user" do
    @al.user_id = nil
    expect(@al.valid?).to eq(false)
  end

  it "must have a place" do
    @al.place = nil
    expect(@al.valid?).to eq(false)
  end

  it "must have a positive place" do
    @al.place = 0
    expect(@al.valid?).to eq(false)
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
      @al = AwardLabel.new
      @al.user = FactoryGirl.build_stubbed(:user)
      @al.populate_from_competitor(@comp, @reg, 1)
    end
    it "Can create the awards label from a competitor" do
      expect(@al.line_1).to eq("#{@reg.first_name} #{@reg.last_name}")
      expect(@al.valid?).to eq(true)
    end

    it "displays both names if in a pair" do
      @reg2 = FactoryGirl.build_stubbed(:competitor, first_name: "Bob", last_name: "Smith")
      allow(@comp).to receive_message_chain(:members, :count).and_return(2)
      allow(@comp).to receive(:registrants).and_return([@reg, @reg2])

      @al.populate_from_competitor(@comp, @reg, 1)
      expect(@al.line_1).to eq("#{@reg.first_name} #{@reg.last_name} & #{@reg2.first_name} #{@reg2.last_name}")
    end

    it "displays the award_title_name as line 2 for freestyle events" do
      competition = @comp.competition
      competition.scoring_class = "Freestyle"
      competition.name = "Hello"
      competition.award_title_name = "Individual"
      competition.save!

      @al.populate_from_competitor(@comp, @reg, 1)
      expect(@al.line_2).to eq("Individual")
    end

    it "displays the award subtitle as line 4" do
      competition = @comp.competition
      competition.name = "Club Freestyle Int"
      competition.award_title_name = "Club Freestyle"
      competition.award_subtitle_name = "Intermediate Club"
      competition.save!

      @al.populate_from_competitor(@comp, @reg, 1)
      expect(@al.line_4).to eq("Intermediate Club")
    end

    it "displays the team name as line 3" do
      @comp.custom_name = "Robin Team"
      @al.populate_from_competitor(@comp, @reg, 1)
      expect(@al.line_3).to eq("Robin Team")
    end

    describe "when the competitor has expert results" do
      before(:each) do
        @comp.competition.scoring_class = "Shortest Time"
        @comp.competition.age_group_type = FactoryGirl.create(:age_group_type)
      end

      it "uses the age group and the gender as line 4" do
        allow(@comp).to receive(:age_group_entry_description).and_return("This is the age group")
        @al.populate_from_competitor(@comp, @reg, 3, false)
        expect(@al.line_4).to eq("This is the age group")
      end

      it "sets the age group to Expert Male when expert" do
        @al.populate_from_competitor(@comp, @reg, 3, true)
        expect(@al.line_4).to eq("Expert Male")
      end
    end

    it "stores the competitor.result as details, and line 5" do
      @al.populate_from_competitor(@comp, @reg, 1)
      expect(@al.line_5).to eq("Some Result")
    end

    it "sets the award place from the competitor" do
      @al.populate_from_competitor(@comp, @reg, 2)
      expect(@al.place).to eq(2)
    end

    it "translates from places to line6" do
      @al.place = 1
      expect(@al.line_6).to eq("1st Place")
      @al.place = 2
      expect(@al.line_6).to eq("2nd Place")
      @al.place = 3
      expect(@al.line_6).to eq("3rd Place")
      @al.place = 4
      expect(@al.line_6).to eq("4th Place")
      @al.place = 5
      expect(@al.line_6).to eq("5th Place")
      @al.place = 6
      expect(@al.line_6).to eq("6th Place")
    end
  end
end
