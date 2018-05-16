class AddCompetitionIdToEventCategories < ActiveRecord::Migration[4.2]
  def change
    add_column :event_categories, :competition_id, :integer
  end
end
