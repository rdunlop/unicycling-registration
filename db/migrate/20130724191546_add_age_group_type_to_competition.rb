class AddAgeGroupTypeToCompetition < ActiveRecord::Migration[4.2]
  def change
    add_column :competitions, :age_group_type_id, :integer
  end
end
