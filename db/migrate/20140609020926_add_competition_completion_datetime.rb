class AddCompetitionCompletionDatetime < ActiveRecord::Migration[4.2]
  def change
    add_column :competitions, :scheduled_completion_at, :datetime
  end
end
