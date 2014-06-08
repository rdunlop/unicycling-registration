class AddUsaConfirmFields < ActiveRecord::Migration
  def change
    add_column :contact_details, :usa_confirmed_paid, :boolean, default: false
    add_column :contact_details, :usa_family_membership_holder_id, :integer
    add_column :event_configurations, :usa_individual_expense_item_id, :integer
    add_column :event_configurations, :usa_family_expense_item_id, :integer
  end
end
