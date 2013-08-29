class AddIWantToVolunteerToRegistrant < ActiveRecord::Migration
  def change
    add_column :registrants, :volunteer, :boolean
  end
end
