class AddHasExpertandHasAgeGroupsToCompetition < ActiveRecord::Migration
  def change
    add_column :competitions, :has_experts, :boolean, default: false
    add_column :competitions, :has_age_groups, :boolean, default: false
  end
end
