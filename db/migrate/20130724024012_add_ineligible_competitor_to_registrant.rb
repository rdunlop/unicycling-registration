class AddIneligibleCompetitorToRegistrant < ActiveRecord::Migration[4.2]
  def change
    add_column :registrants, :ineligible, :boolean, default: false
  end
end
