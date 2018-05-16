class RemoveLongDescriptionAgeGroupEntry < ActiveRecord::Migration[4.2]
  def change
    remove_column :age_group_entries, :long_description, :string
  end
end
