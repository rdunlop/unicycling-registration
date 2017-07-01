# == Schema Information
#
# Table name: results
#
#  id             :integer          not null, primary key
#  competitor_id  :integer
#  result_type    :string(255)
#  result_subtype :integer
#  place          :integer
#  status         :string(255)
#  created_at     :datetime
#  updated_at     :datetime
#
# Indexes
#
#  index_results_on_competitor_id_and_result_type  (competitor_id,result_type) UNIQUE
#

require 'spec_helper'

describe Result do
  before(:each) do
    @result = FactoryGirl.create(:result)
  end
  it "is valid from FactoryGirl" do
    expect(@result).to be_valid
  end

  it "only allows a single result per result-type/competitor pair" do
    result2 = FactoryGirl.build(:result, competitor: @result.competitor, result_type: @result.result_type)
    expect(result2).to be_invalid
  end

  it "allows multiple results for the same competitor, with different result_types" do
    expect(@result.result_type).to eq("AgeGroup")
    result2_overall = FactoryGirl.build(:result, competitor: @result.competitor, result_type: "Overall")
    expect(result2_overall).to be_valid
  end
end

describe Result do
  before(:each) do
    @al = FactoryGirl.build_stubbed(:result, place: 2)
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
      allow(@al).to receive(:competitor).and_return(@comp)
    end

    it "Can name the registrant(s)" do
      expect(@al.competitor_name(@reg)).to eq("#{@reg.first_name} #{@reg.last_name}")
    end

    it "displays both names if in a pair" do
      @reg2 = FactoryGirl.build_stubbed(:competitor, first_name: "Bob", last_name: "Smith")
      allow(@comp).to receive_message_chain(:active_members, :size).and_return(2)
      allow(@comp).to receive(:registrants).and_return([@reg, @reg2])
      expect(@al.competitor_name(@reg)).to eq("#{@reg.first_name} #{@reg.last_name} & #{@reg2.first_name} #{@reg2.last_name}")
    end

    it "displays the award_title_name as line 2 for freestyle events" do
      competition = @comp.competition
      competition.scoring_class = "Freestyle"
      competition.name = "Hello"
      competition.award_title_name = "Individual"
      competition.save!

      expect(@al.competition_name).to eq("Individual")
    end

    it "displays the award subtitle as line 4" do
      competition = @comp.competition
      competition.name = "Club Freestyle Int"
      competition.award_title_name = "Club Freestyle"
      competition.award_subtitle_name = "Intermediate Club"
      competition.save!

      expect(@al.category_name).to eq("Intermediate Club")
    end

    it "displays the team name as line 3" do
      @comp.custom_name = "Robin Team"
      expect(@al.team_name).to eq("Robin Team")
    end

    describe "when the competitor has expert results" do
      before(:each) do
        @comp.competition.scoring_class = "Shortest Time"
        @comp.competition.age_group_type = FactoryGirl.create(:age_group_type)
      end

      it "uses the age group and the gender as line 4" do
        allow(@comp).to receive(:age_group_entry_description).and_return("This is the age group")
        expect(@al.category_name).to eq("This is the age group")
      end

      it "sets the age group to Expert Male when expert" do
        allow(@comp.competition).to receive(:has_experts?).and_return(true)
        allow(@al).to receive(:age_group_type?).and_return(false)
        expect(@al.category_name).to eq("Expert Male")
      end
    end

    it "stores the competitor.result as details, and line 5" do
      expect(@al.details).to eq("Some Result")
    end

    it "sets the award place from the competitor" do
      expect(@al.place).to eq(2)
    end
  end
end
