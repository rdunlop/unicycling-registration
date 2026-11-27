# The age groups competitors of a competition are ranked in.
#
# These are the entries of the competition's AgeGroupType, viewed through the
# competition's AgeGroupCombinations: combined entries are ranked together,
# without the AgeGroupType itself being modified.
# Likewise, the competition may order its age groups itself (see AgeGroupPosition).
module CompetitionAgeGroups
  extend ActiveSupport::Concern

  included do
    has_many :age_group_combinations, dependent: :destroy, inverse_of: :competition
    has_many :age_group_positions, dependent: :delete_all

    validate :no_published_age_group_combinations, on: :update, if: :will_save_change_to_age_group_type_id?
    after_update :remove_age_group_combinations, if: :saved_change_to_age_group_type_id?
  end

  # The age groups competitors are ranked in (and heats are ordered by):
  # each AgeGroupEntry, unless it is part of an AgeGroupCombination, in which case the combination.
  #
  # They are in the competition's own order if it has one (entries without a position last),
  # in age group type order otherwise.
  def age_groups
    return [] if age_group_type.nil?

    age_groups = age_group_type.age_group_entries.map { |entry| age_group_for(entry) }.uniq
    return age_groups unless custom_age_group_order?

    age_groups.each_with_index.sort_by { |age_group, index| [competition_position(age_group) || Float::INFINITY, index] }.map(&:first)
  end

  def custom_age_group_order?
    age_group_cache[:positions_by_entry_id].any?
  end

  # Move the age group to the given (0-based) index of the competition's own order,
  # the current order of the other age groups becoming the competition's own order
  def move_age_group(age_group, index)
    raise ArgumentError, "#{age_group} is not an age group of #{self}" unless age_groups.include?(age_group)

    ordered_age_groups = age_groups - [age_group]
    ordered_age_groups.insert(index.clamp(0, ordered_age_groups.size), age_group)

    rows = ordered_age_groups.each_with_index.flat_map do |ordered_age_group, position|
      ordered_age_group.age_group_entry_ids.map { |entry_id| { age_group_entry_id: entry_id, position: position + 1 } }
    end
    transaction do
      age_group_positions.delete_all
      age_group_positions.insert_all!(rows)
    end
    age_group_order_changed
  end

  # Use the age group type order again
  def reset_age_group_order
    age_group_positions.delete_all
    age_group_order_changed
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

      {
        combinations_by_entry_id: combinations_by_entry_id,
        positions_by_entry_id: age_group_positions.pluck(:age_group_entry_id, :position).to_h
      }
    end
  end

  # A combination takes the place of its first entry
  def competition_position(age_group)
    age_group.age_group_entry_ids.filter_map { |entry_id| age_group_cache[:positions_by_entry_id][entry_id] }.min
  end

  def age_group_order_changed
    AgeGroupCombinationCache.expire(id)
    touch
  end

  # Changing the age group type removes the combinations, which would also remove their published results
  def no_published_age_group_combinations
    return unless published_age_group_combinations?

    errors.add(:age_group_type_id, "cannot be changed while combined age group results are published, unpublish them first")
  end

  # Combinations (and positions) are only meaningful for the entries of the previous age group type
  def remove_age_group_combinations
    age_group_combinations.destroy_all
    age_group_positions.delete_all
  end
end
