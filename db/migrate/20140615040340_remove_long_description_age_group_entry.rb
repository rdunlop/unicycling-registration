class RemoveLongDescriptionAgeGroupEntry < ActiveRecord::Migration
  def change
    remove_column :age_group_entries, :long_description, :string
  end
end
