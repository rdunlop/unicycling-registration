class UpdateFieldsInRegistrant < ActiveRecord::Migration
  def up
    remove_column :registrants, :address_line_1
    remove_column :registrants, :address_line_2
    remove_column :registrants, :city
    remove_column :registrants, :zip_code

    add_column :registrants, :club, :string
    add_column :registrants, :club_contact, :string
    add_column :registrants, :usa_member_number, :string
    add_column :registrants, :emergency_name, :string
    add_column :registrants, :emergency_relationship, :string
    add_column :registrants, :emergency_attending, :boolean
    add_column :registrants, :emergency_primary_phone, :string
    add_column :registrants, :emergency_other_phone, :string
    add_column :registrants, :responsible_adult_name, :string
    add_column :registrants, :responsible_adult_phone, :string
  end

  def down; end
end
