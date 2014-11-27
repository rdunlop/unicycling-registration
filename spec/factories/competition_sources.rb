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
#  min_age               :integer
#  max_age               :integer
#
# Indexes
#
#  index_competition_sources_competition_id         (competition_id)
#  index_competition_sources_event_category_id      (event_category_id)
#  index_competition_sources_target_competition_id  (target_competition_id)
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :competition_source do
    target_competition factory: :competition
    competition nil
    event_category nil
    max_place nil
    gender_filter "Both"
    before(:create) do |competition_source|
      if competition_source.event_category.nil?
        ev = FactoryGirl.create(:event)
        competition_source.event_category = ev.event_categories.first
      end
    end
  end
end
