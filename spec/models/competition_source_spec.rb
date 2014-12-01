# == Schema Information
#
# Table name: competition_sources
#
#  id                    :integer          not null, primary key
#  target_competition_id :integer
#  event_category_id     :integer
#  competition_id        :integer
#  gender_filter         :string(255)
#  max_place             :integer
#  created_at            :datetime
#  updated_at            :datetime
#  min_age               :integer
#  max_age               :integer
#
# Indexes
#
#  index_competition_sources_competition_id         (competition_id)
#  index_competition_sources_event_category_id      (event_category_id)
#  index_competition_sources_target_competition_id  (target_competition_id)
#

require 'spec_helper'

describe CompetitionSource do
  before(:each) do
    @competition = FactoryGirl.create(:competition)
    @cs = FactoryGirl.create(:competition_source, :target_competition => @competition)
  end
  it "is valid from FactoryGirl" do
    @cs.valid?.should == true
  end

  it "requires a gender_filter" do
    @cs.gender_filter = nil
    @cs.valid?.should == false
  end
  it "requires an target_competition" do
    @cs.target_competition = nil
    @cs.valid?.should == false
  end

  it "requires a competition or event_category" do
    @cs.event_category = nil
    @cs.competition = nil
    @cs.valid?.should == false
  end

  it "cannot select max_place without choosing competition" do
    @cs.competition = nil
    @cs.max_place = 1
    @cs.valid?.should == false

    @cs.competition = FactoryGirl.create(:competition)
    @cs.valid?.should == true
  end

  it "can be found from the competition" do
    @competition.competition_sources.should == [@cs]
  end

  describe "with a competition_source targetting another competition" do
    before(:each) do
      @competition2 = FactoryGirl.create(:competition)
      @source_competition = FactoryGirl.create(:ranked_competition)
      @cs2 = FactoryGirl.create(:competition_source, :competition => @source_competition, :target_competition => @competition2, :max_place => 2)
    end

    it "chooses competitors from the source_competition with a good enough overall_place", :caching => true do
      @competitor = FactoryGirl.create(:event_competitor, :competition => @source_competition)
      FactoryGirl.create(:result, place: 1, result_type: "Overall", competitor: @competitor)

      @cs2.signed_up_registrants.count.should == 1
    end
    it "doesn't choose a competitor with an overall_place worse than the required" do
      @competitor = FactoryGirl.create(:event_competitor, :competition => @source_competition)
      FactoryGirl.create(:result, place: 3, result_type: "Overall", competitor: @competitor)

      @cs2.signed_up_registrants.count.should == 0
    end
  end

  describe "when a competition_source is filtered by age" do
    it "chooses competitors with the age filter" do
      reg = FactoryGirl.create(:competitor)
      ec = @cs.event_category
      allow(ec).to receive(:signed_up_registrants).and_return([reg])
      allow(reg).to receive(:age).and_return(11)
      @cs.min_age = 10
      @cs.max_age = 11
      @cs.signed_up_registrants.count.should == 1
    end
  end
end
