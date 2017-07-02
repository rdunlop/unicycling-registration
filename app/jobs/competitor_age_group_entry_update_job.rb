class CompetitorAgeGroupEntryUpdateJob < ApplicationJob
  # Determine the Competitor's assigned age group, and update, if necessary
  def perform(competitor_id)
    competitor = Competitor.find(competitor_id)
    competition = competitor.competition
    return if competition.age_group_type.blank?

    if competitor.active_members.none?
      new_age_group_entry_id = nil
    else
      new_age_group_entry = competition.age_group_type.age_group_entry_for(competitor.age, competitor.gender, competitor.wheel_size)
      new_age_group_entry_id = new_age_group_entry.try(:id) || nil
    end

    if new_age_group_entry_id.nil?
      Rollbar.error("Unable to find suitable age group entry for competitor #{competitor_id} in #{Apartment::Tenant.current}")
    end

    return if competitor.age_group_entry_id == new_age_group_entry_id
    competitor.update_attribute(:age_group_entry_id, new_age_group_entry_id)
  end
end
