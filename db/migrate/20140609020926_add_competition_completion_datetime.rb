class AddCompetitionCompletionDatetime < ActiveRecord::Migration
  def change
    add_column :competitions, :scheduled_completion_at, :datetime
  end
end
