# == Schema Information
#
# Table name: competitions
#
#  id                                    :integer          not null, primary key
#  event_id                              :integer
#  name                                  :string
#  created_at                            :datetime
#  updated_at                            :datetime
#  age_group_type_id                     :integer
#  has_experts                           :boolean          default(FALSE), not null
#  scoring_class                         :string
#  start_data_type                       :string
#  end_data_type                         :string
#  uses_lane_assignments                 :boolean          default(FALSE), not null
#  scheduled_completion_at               :datetime
#  awarded                               :boolean          default(FALSE), not null
#  award_title_name                      :string
#  award_subtitle_name                   :string
#  num_members_per_competitor            :string
#  automatic_competitor_creation         :boolean          default(FALSE), not null
#  combined_competition_id               :integer
#  order_finalized                       :boolean          default(FALSE), not null
#  penalty_seconds                       :integer
#  locked_at                             :datetime
#  published_at                          :datetime
#  sign_in_list_enabled                  :boolean          default(FALSE), not null
#  time_entry_columns                    :string           default("minutes_seconds_thousands")
#  import_results_into_other_competition :boolean          default(FALSE), not null
#  base_age_group_type_id                :integer
#  score_ineligible_competitors          :boolean          default(FALSE), not null
#  results_header                        :string
#  hide_max_laps_count                   :boolean          default(FALSE), not null
#
# Indexes
#
#  index_competitions_event_id                    (event_id)
#  index_competitions_on_base_age_group_type_id   (base_age_group_type_id)
#  index_competitions_on_combined_competition_id  (combined_competition_id) UNIQUE
#

require 'spec_helper'

describe Competition do
  before do
    @ev = FactoryBot.create(:event)
    @ec = FactoryBot.create(:competition, event: @ev)
  end

  it "is valid from FactoryBot" do
    expect(@ec.valid?).to eq(true)
  end

  it "allows a start_data_type" do
    @ec.start_data_type = "One Data Per Line"
    expect(@ec.valid?).to eq(true)
  end

  it "allows blank start_data_type" do
    @ec.start_data_type = nil
    expect(@ec).to be_valid
    @ec.start_data_type = ""
    expect(@ec).to be_valid
  end

  it "requires an event" do
    @ec.event = nil
    expect(@ec.valid?).to eq(false)
  end

  it "requires a name" do
    @ec.name = nil
    expect(@ec.valid?).to eq(false)
  end

  describe "the scoring_class" do
    it "cannot be blank" do
      @ec.scoring_class = nil
      expect(@ec.valid?).to eq(false)
    end

    it "can be Freestyle" do
      @ec.scoring_class = "Freestyle"
      expect(@ec.valid?).to eq(true)
    end

    it "can be Flatland" do
      @ec.scoring_class = "Flatland"
      expect(@ec.valid?).to eq(true)
    end

    it "can be Street" do
      @ec.scoring_class = "Street"
      expect(@ec.valid?).to eq(true)
    end

    it "can be High/Long" do
      @ec.scoring_class = "High/Long"
      @ec.age_group_type = FactoryBot.build_stubbed(:age_group_type)
      expect(@ec.valid?).to eq(true)
    end

    it "can be overall Champion" do
      @ec.scoring_class = "Overall Champion"
      expect(@ec).to be_invalid
      @ec.combined_competition = FactoryBot.create(:combined_competition)
      expect(@ec).to be_valid
    end
  end

  it "is not_expert by default" do
    comp = described_class.new
    expect(comp.has_experts).to eq(false)
  end

  describe "with a user" do
    before do
      @user = FactoryBot.create(:user)
    end

    it "says there are no judges" do
      expect(@ec.has_judge(@user)).to eq(false)
      expect(@ec.get_judge(@user)).to be_nil
    end

    describe "as a judge" do
      before do
        @judge = FactoryBot.create(:judge, competition: @ec, user: @user)
      end

      it "has judge" do
        expect(@ec.has_judge(@user)).to eq(true)
        expect(@ec.get_judge(@user)).to eq(@judge)
      end
    end
  end

  it "Cannot be published until it is locked" do
    @ec.locked_at = nil
    @ec.published_at = Time.current
    expect(@ec).to be_invalid
  end

  it "Cannot be awarded until it is published" do
    @ec.locked_at = Time.current
    @ec.published_at = nil
    @ec.awarded = true
    expect(@ec).to be_invalid
  end

  it "can create a competitor from registrants" do
    regs = [FactoryBot.create(:competitor),
            FactoryBot.create(:competitor),
            FactoryBot.create(:competitor)]
    @ec.create_competitor_from_registrants(regs, "Robin's Team")
    comp = Competitor.last
    expect(comp.members.count).to eq(3)
    expect(comp.name).to eq("Robin's Team")
  end

  it "has an event" do
    expect(@ec.event).to eq(@ev)
  end

  it "uses the event name in its name" do
    expect(@ec.to_s).to eq(@ec.name)
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
