class AddIneligibleCompetitorToRegistrant < ActiveRecord::Migration
  def change
    add_column :registrants, :ineligible, :boolean, default: false
  end
end
