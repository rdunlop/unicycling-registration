class AddNameToAgeGroupCombinations < ActiveRecord::Migration[8.1]
  def change
    # Optional custom name, the names of the combined entries being used otherwise
    add_column :age_group_combinations, :name, :string
  end
end
