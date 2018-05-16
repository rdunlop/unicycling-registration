class AddAddressToRegistrant < ActiveRecord::Migration[4.2]
  def change
    add_column :registrants, :address, :string
    add_column :registrants, :city, :string
    add_column :registrants, :zip, :string
  end
end
