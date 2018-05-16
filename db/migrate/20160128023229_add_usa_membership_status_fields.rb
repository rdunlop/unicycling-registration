class AddUsaMembershipStatusFields < ActiveRecord::Migration[4.2]
  def change
    add_column :contact_details, :usa_member_number_valid, :boolean, default: false, null: false
    add_column :contact_details, :usa_member_number_status, :string
  end
end
