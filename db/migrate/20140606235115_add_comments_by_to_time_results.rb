class AddCommentsByToTimeResults < ActiveRecord::Migration[4.2]
  def change
    add_column :time_results, :comments_by, :string
    add_column :import_results, :comments_by, :string
  end
end
