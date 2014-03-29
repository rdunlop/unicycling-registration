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
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
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
      @cs2 = FactoryGirl.create(:competition_source, :target_competition => @source_competition, :max_place => 2)

      it "chooses competitors from the source_competition with a good enough overall_place", :caching => true do
        @competitor = FactoryGirl.create(:event_competitor, :competition => @source_competition)
        @competitor.overall_place = 1

        @cs2.signed_up_registrants.count.should == 1
      end
      it "doesn't choose a competitor with an overall_place worse than the required" do
        @competitor = FactoryGirl.create(:event_competitor, :competition => @source_competition)
        @competitor.overall_place = 3

        @cs2.signed_up_registrants.count.should == 0
      end
    end
  end
end
