# Combines (and separates) the age groups of a competition.
#
# Combinations are views over the competition's AgeGroupEntries:
# the entries themselves are never modified, so separating a combination
# restores the original age groups.
class AgeGroupCombiner
  attr_reader :competition, :error_message

  def initialize(competition)
    @competition = competition
  end

  # Combine two neighbouring age groups (AgeGroupEntry or AgeGroupCombination)
  # into a single AgeGroupCombination
  def combine(first_age_group, second_age_group)
    return false unless can_combine?(first_age_group, second_age_group)

    AgeGroupCombination.transaction do
      age_group_entries = first_age_group.age_group_entries.to_a + second_age_group.age_group_entries.to_a
      existing_combinations = [first_age_group, second_age_group].grep(AgeGroupCombination)
      combination = existing_combinations.first || competition.age_group_combinations.create!

      (existing_combinations - [combination]).each(&:destroy!)
      # A custom name describes the previous age groups of the combination
      combination.update!(name: nil)
      (age_group_entries - combination.age_group_entries.to_a).each do |age_group_entry|
        combination.age_group_combination_entries.create!(age_group_entry: age_group_entry)
      end
    end
    competition.reload

    true
  rescue ActiveRecord::RecordNotUnique
    # Another request combined one of these age groups concurrently
    @error_message = "#{first_age_group} or #{second_age_group} has just been combined, please try again"
    competition.reload
    false
  end

  # Remove the combination, restoring its age group entries as separate age groups
  def separate(combination)
    if published?(combination)
      @error_message = "#{combination} results are published, unpublish them first"
      return false
    end

    combination.destroy!
    competition.reload

    true
  end

  # Give the combination a custom name (a blank name restores the default name)
  def rename(combination, name)
    if published?(combination)
      @error_message = "#{combination} results are published, unpublish them first"
      return false
    end

    unless combination.update(name: name)
      @error_message = combination.errors.full_messages.to_sentence
      return false
    end
    competition.reload

    true
  end

  # The contiguous neighbour of the given age group with the fewest eligible registrants
  def smallest_neighbour(age_group, registrant_data)
    candidates = competition.age_groups.select { |other| same_category?(age_group, other) }.sort_by(&:start_age)
    index = candidates.index(age_group)
    return if index.nil?

    previous_neighbour = candidates[index - 1] if index.positive?
    next_neighbour = candidates[index + 1]

    [next_neighbour, previous_neighbour]
      .compact
      .select { |neighbour| contiguous?(age_group, neighbour) }
      .min_by { |neighbour| neighbour.number_eligible_matching_registrant(registrant_data) }
  end

  private

  def can_combine?(first_age_group, second_age_group)
    @error_message = if first_age_group.nil? || second_age_group.nil? || first_age_group == second_age_group
                       "Must choose 2 different age groups"
                     elsif first_age_group.gender != second_age_group.gender
                       "Age Groups must be the same gender"
                     elsif first_age_group.wheel_size_id != second_age_group.wheel_size_id
                       "Age Groups must be the same wheel size"
                     elsif !contiguous?(first_age_group, second_age_group)
                       "Age Groups must be contiguous"
                     elsif (published_age_group = [first_age_group, second_age_group].find { |age_group| published?(age_group) })
                       "#{published_age_group} results are published, unpublish them first"
                     end

    @error_message.nil?
  end

  def same_category?(age_group, other)
    age_group.gender == other.gender && age_group.wheel_size_id == other.wheel_size_id
  end

  def contiguous?(age_group, other)
    younger, older = [age_group, other].sort_by(&:start_age)
    younger.end_age + 1 == older.start_age
  end

  def published?(age_group)
    competition.published_age_group_entry_for(age_group).present?
  end
end
