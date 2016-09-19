class AgeGroupTypeDuplicator
  attr_accessor :age_group_type, :new_age_group_type

  def initialize(age_group_type)
    @age_group_type = age_group_type
  end

  # On Success, store the new AgeGroupType in :new_age_group_type
  def duplicate
    new_type = @age_group_type.dup
    new_type.age_group_entries = @age_group_type.age_group_entries.collect do |entry|
      new_entry = entry.dup
      new_entry.age_group_type = new_type
      new_entry
    end

    new_type.name += " (Copy)"

    @new_age_group_type = new_type
    new_type.save
  end
end
