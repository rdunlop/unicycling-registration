# Shared behaviour of the age groups competitors are ranked in,
# whether a single AgeGroupEntry or an AgeGroupCombination.
#
# Requires `gender`, `start_age`, `end_age` and `age_group_entry_ids`.
module AgeGroupMatching
  def number_matching_registrant(registrant_data)
    matching_registrant_data(registrant_data).sum { |element| element[:count] }
  end

  def number_ineligible_matching_registrant(registrant_data)
    matching_registrant_data(registrant_data).select { |element| element[:ineligible] }.sum { |element| element[:count] }
  end

  def number_eligible_matching_registrant(registrant_data)
    matching_registrant_data(registrant_data).reject { |element| element[:ineligible] }.sum { |element| element[:count] }
  end

  def includes_age_group_entry?(age_group_entry)
    age_group_entry.present? && age_group_entry_ids.include?(age_group_entry.id)
  end

  private

  def matching_registrant_data(registrant_data)
    registrant_data.select do |element|
      element[:gender] == gender && start_age <= element[:age] && element[:age] <= end_age
    end
  end
end
