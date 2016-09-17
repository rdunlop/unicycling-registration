class AddBaseAgeGroupTypeToCompetition < ActiveRecord::Migration
  def change
    add_column :competitions, :base_age_group_type_id, :integer
    add_index :competitions, :base_age_group_type_id
  end
end
