class AgeGroupEntryCombiner
  attr_accessor :first_age_group_entry_id, :second_age_group_entry_id, :error_message

  def initialize(first_age_group_entry_id, second_age_group_entry_id)
    @first_age_group_entry_id = first_age_group_entry_id
    @second_age_group_entry_id = second_age_group_entry_id
  end

  def combine
    age_group_entries = age_group_type.age_group_entries_by_age_gender.where(id: [first_age_group_entry_id, second_age_group_entry_id])
    smallest_age_group_entry = age_group_entries.first

    other_entry = (age_group_entries - [smallest_age_group_entry]).first

    max_age = smallest_age_group_entry.end_age
    if other_entry.gender != smallest_age_group_entry.gender
      @error_message = "Age Group Entries must be the same gender"
      return false
    end
    if other_entry.start_age != max_age + 1
      @error_message = "Age Group Entries must be contiguous"
      return false
    end
    max_age = other_entry.end_age

    AgeGroupEntry.transaction do
      smallest_age_group_entry.end_age = max_age
      smallest_age_group_entry.short_description = "#{smallest_age_group_entry.short_description} and #{other_entry.short_description}"
      smallest_age_group_entry.save!
      other_entry.destroy!
    end

    true
  end

  private

  def age_group_type
    return nil unless first_age_group_entry.present?

    first_age_group_entry.age_group_type
  end

  def first_age_group_entry
    AgeGroupEntry.find(first_age_group_entry_id)
  end
end
