class RemoveHasAgeGroupFromCompetition < ActiveRecord::Migration[4.2]
  def up
    remove_column :competitions, :has_age_groups, :boolean
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
