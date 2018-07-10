class SetDefaultFeedbackSubject < ActiveRecord::Migration[5.1]
  def up
    execute "UPDATE feedbacks SET subject = 'n/a'"
  end

  def down; end
end
