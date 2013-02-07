class AddAddressToRegistrant < ActiveRecord::Migration
  def change
    add_column :registrants, :address, :string
    add_column :registrants, :city, :string
    add_column :registrants, :zip, :string
  end
end
