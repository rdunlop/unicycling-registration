class AddHasExpertandHasAgeGroupsToCompetition < ActiveRecord::Migration[4.2]
  def change
    add_column :competitions, :has_experts, :boolean, default: false
    add_column :competitions, :has_age_groups, :boolean, default: false
  end
end
