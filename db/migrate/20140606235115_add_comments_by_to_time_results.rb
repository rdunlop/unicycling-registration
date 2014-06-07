class AddCommentsByToTimeResults < ActiveRecord::Migration
  def change
    add_column :time_results, :comments_by, :string
    add_column :import_results, :comments_by, :string
  end
end
