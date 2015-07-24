class RenameColumnsInAwardLabel < ActiveRecord::Migration
  def change
    rename_column :award_labels, :competitor_name, :line_1
    rename_column :award_labels, :competition_name, :line_2
    rename_column :award_labels, :team_name, :line_3
    rename_column :award_labels, :category, :line_4
    rename_column :award_labels, :details, :line_5
  end
end
