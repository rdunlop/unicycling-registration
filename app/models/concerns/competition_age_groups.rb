# The age groups competitors of a competition are ranked in.
#
# These are the entries of the competition's AgeGroupType, viewed through the
# competition's AgeGroupCombinations: combined entries are ranked together,
# without the AgeGroupType itself being modified.
module CompetitionAgeGroups
  extend ActiveSupport::Concern

  included do
    has_many :age_group_combinations, dependent: :destroy, inverse_of: :competition

    validate :no_published_age_group_combinations, on: :update, if: :will_save_change_to_age_group_type_id?
    after_update :remove_age_group_combinations, if: :saved_change_to_age_group_type_id?
  end

  # The age groups competitors are ranked in (and heats are ordered by), in age group type order:
  # each AgeGroupEntry, unless it is part of an AgeGroupCombination, in which case the combination.
  def age_groups
    return [] if age_group_type.nil?

    age_group_type.age_group_entries.map { |entry| age_group_for(entry) }.uniq
  end

  # The age group (AgeGroupEntry or AgeGroupCombination) a competitor in the given entry is ranked in
  def age_group_for(age_group_entry)
    return if age_group_entry.nil?

    age_group_cache[:combinations_by_entry_id].fetch(age_group_entry.id, age_group_entry)
  end

  # Find an age group from its #to_age_group_param
  # (a bare id is an AgeGroupEntry id, as used by URLs prior to combinations)
  def find_age_group(param)
    param = "entry-#{param}" if param.to_s.match?(/\A\d+\z/)
    age_groups.find { |age_group| age_group.to_age_group_param == param }
  end

  def find_age_group!(param)
    find_age_group(param) || raise(ActiveRecord::RecordNotFound, "Couldn't find age group #{param}")
  end

  def competitors_in(age_group)
    competitors.where(age_group_entry_id: age_group.age_group_entry_ids)
  end

  def published_age_group_entry_for(age_group)
    if age_group.is_a?(AgeGroupCombination)
      published_age_group_entries.find_by(age_group_combination: age_group)
    else
      published_age_group_entries.find_by(age_group_entry: age_group)
    end
  end

  def published_age_group_combinations?
    published_age_group_entries.where.not(age_group_combination_id: nil).exists?
  end

  def reload(*)
    AgeGroupCombinationCache.expire(id)
    super
  end

  private

  def age_group_cache
    AgeGroupCombinationCache.fetch(id) do
      combinations_by_entry_id = age_group_combinations.includes(:age_group_entries).each_with_object({}) do |combination, by_entry_id|
        combination.age_group_entries.each { |entry| by_entry_id[entry.id] = combination }
      end

      { combinations_by_entry_id: combinations_by_entry_id }
    end
  end

  # Changing the age group type removes the combinations, which would also remove their published results
  def no_published_age_group_combinations
    return unless published_age_group_combinations?

    errors.add(:age_group_type_id, "cannot be changed while combined age group results are published, unpublish them first")
  end

  # Combinations are only meaningful for the entries of the previous age group type
  def remove_age_group_combinations
    age_group_combinations.destroy_all
  end
end
