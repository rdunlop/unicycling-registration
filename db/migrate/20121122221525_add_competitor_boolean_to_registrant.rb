class AddCompetitorBooleanToRegistrant < ActiveRecord::Migration
  def change
    add_column :registrants, :competitor, :boolean
  end
end
