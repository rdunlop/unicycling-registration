class SetDefaultFeedbackSubject < ActiveRecord::Migration[5.1]
  def change
    execute "UPDATE feedbacks SET subject = 'n/a'"
  end
end
