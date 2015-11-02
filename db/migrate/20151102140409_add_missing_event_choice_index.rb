class AddMissingEventChoiceIndex < ActiveRecord::Migration
  def change
    add_index :coupon_code_expense_items, [:coupon_code_id]
    add_index :coupon_code_expense_items, [:expense_item_id]
    add_index :event_choices, [:event_id, :position]
    add_index :payment_detail_coupon_codes, [:payment_detail_id]
    add_index :payment_detail_coupon_codes, [:coupon_code_id]
    add_index :published_age_group_entries, [:competition_id]
    add_index :two_attempt_entries, [:competition_id, :is_start_time, :id], name: "index_two_attempt_entries_ids"
  end
end
