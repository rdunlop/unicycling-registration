class RulesForTeamsIncludingIneligibleMembers < ActiveRecord::Migration[8.1]
  def up
    # Defaults match the previous behavior: 100% of members should be eligible (score_ineligible_competitors was false by default)
    add_column :competitions, :rule_for_ineligible_competitors, :integer, null: false, default: 100
    execute <<-SQL
        UPDATE competitions
        SET rule_for_ineligible_competitors = CASE WHEN score_ineligible_competitors THEN 0 ELSE 100 END
    SQL
    remove_column :competitions, :score_ineligible_competitors, :boolean, null: false
  end

  def down
    add_column :competitions, :score_ineligible_competitors, :boolean, null: false, default: false
    execute <<-SQL
        UPDATE competitions
        SET score_ineligible_competitors = (rule_for_ineligible_competitors = 0)
    SQL
    remove_column :competitions, :rule_for_ineligible_competitors, :integer, null: false
  end
end
