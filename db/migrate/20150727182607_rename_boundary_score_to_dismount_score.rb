class RenameBoundaryScoreToDismountScore < ActiveRecord::Migration
  def up
    rename_table :boundary_scores, :dismount_scores
    remove_column :dismount_scores, :number_of_people
    remove_column :dismount_scores, :major_boundary
    remove_column :dismount_scores, :minor_boundary
  end

  def down
    rename_table :dismount_scores, :boundary_scores
    add_column :boundary_scores, :number_of_people, :integer
    add_column :boundary_scores, :major_boundary, :integer
    add_column :boundary_scores, :minor_boundary, :integer
  end
end
