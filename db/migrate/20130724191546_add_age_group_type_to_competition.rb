class AddAgeGroupTypeToCompetition < ActiveRecord::Migration
  def change
    add_column :competitions, :age_group_type_id, :integer
  end
end
