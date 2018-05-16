class AddIWantToVolunteerToRegistrant < ActiveRecord::Migration[4.2]
  def change
    add_column :registrants, :volunteer, :boolean
  end
end
