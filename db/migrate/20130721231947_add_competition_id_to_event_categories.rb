class AddCompetitionIdToEventCategories < ActiveRecord::Migration
  def change
    add_column :event_categories, :competition_id, :integer
  end
end
