class AddSubjectToFeedback < ActiveRecord::Migration[5.1]
  def change
    add_column :feedbacks, :subject, :text
  end
end
