class RemoveHasAgeGroupFromCompetition < ActiveRecord::Migration
  def up
    remove_column :competitions, :has_age_groups, :boolean
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
