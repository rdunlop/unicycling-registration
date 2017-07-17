class AddCompetitionAllowIneligibleCompetitors < ActiveRecord::Migration[5.0]
  def change
    add_column :competitions, :score_ineligible_competitors, :boolean, default: false, null: false
  end
end
