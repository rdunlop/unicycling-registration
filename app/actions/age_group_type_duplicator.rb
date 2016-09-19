class AgeGroupTypeDuplicator
  attr_accessor :age_group_type

  def initialize(age_group_type)
    @age_group_type = age_group_type
  end

  def duplicate
    new_age_group_type = @age_group_type.dup
    new_age_group_type.age_group_entries = @age_group_type.age_group_entries.collect do |entry|
      new_entry = entry.dup
      new_entry.age_group_type = new_age_group_type
      new_entry
    end

    new_age_group_type.name += " (Copy)"
    new_age_group_type.save
  end
end
