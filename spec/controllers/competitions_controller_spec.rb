# == Schema Information
#
# Table name: competitions
#
#  id                            :integer          not null, primary key
#  event_id                      :integer
#  name                          :string(255)
#  created_at                    :datetime
#  updated_at                    :datetime
#  age_group_type_id             :integer
#  has_experts                   :boolean          default(FALSE), not null
#  scoring_class                 :string(255)
#  start_data_type               :string(255)
#  end_data_type                 :string(255)
#  uses_lane_assignments         :boolean          default(FALSE), not null
#  scheduled_completion_at       :datetime
#  awarded                       :boolean          default(FALSE), not null
#  award_title_name              :string(255)
#  award_subtitle_name           :string(255)
#  num_members_per_competitor    :string(255)
#  automatic_competitor_creation :boolean          default(FALSE), not null
#  combined_competition_id       :integer
#  order_finalized               :boolean          default(FALSE), not null
#  penalty_seconds               :integer
#  locked_at                     :datetime
#  published_at                  :datetime
#  sign_in_list_enabled          :boolean          default(FALSE), not null
#
# Indexes
#
#  index_competitions_event_id                    (event_id)
#  index_competitions_on_combined_competition_id  (combined_competition_id) UNIQUE
#

require 'spec_helper'

describe CompetitionsController do
  before(:each) do
    @admin_user = FactoryGirl.create(:super_admin_user)
    sign_in @admin_user
    @event = FactoryGirl.create(:event)
    @event_category = @event.event_categories.first
  end

  describe "POST lock" do
    it "locks the competition" do
      competition = FactoryGirl.create(:competition, event: @event)
      post :lock, id: competition.to_param
      competition.reload
      expect(competition.locked?).to eq(true)
    end
  end
  describe "DELETE lock" do
    it "unlocks the competition" do
      competition = FactoryGirl.create(:competition, :locked, event: @event)
      delete :unlock, id: competition.to_param
      competition.reload
      expect(competition.locked?).to eq(false)
    end
  end

  describe "POST publish" do
    it "publishes the competition results" do
      competition = FactoryGirl.create(:competition, :locked, event: @event)
      post :publish, id: competition.to_param
      competition.reload
      expect(competition.published?).to eq(true)
    end
  end
  describe "DELETE publish" do
    it "un-publishes the competition" do
      competition = FactoryGirl.create(:competition, :locked, :published, event: @event)
      delete :unpublish, id: competition.to_param
      competition.reload
      expect(competition.published?).to eq(false)
    end
  end
end
