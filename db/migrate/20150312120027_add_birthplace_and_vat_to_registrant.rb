class AddBirthplaceAndVatToRegistrant < ActiveRecord::Migration[4.2]
  def change
    add_column :contact_details, :birthplace, :string
    add_column :contact_details, :vat_number, :string

    add_column :event_configurations, :vat_mode, :boolean, default: false, null: false
  end
end
