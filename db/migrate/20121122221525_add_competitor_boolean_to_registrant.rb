class AddCompetitorBooleanToRegistrant < ActiveRecord::Migration[4.2]
  def change
    add_column :registrants, :competitor, :boolean
  end
end
