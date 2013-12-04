class AddForeignIndexes < ActiveRecord::Migration
  def change
    add_index :registrants, :user_id
    add_index :award_labels, :user_id
    add_index :external_results, :competitor_id
    add_index :import_results, :user_id
    add_index :lane_assignments, :competition_id
    add_index :refund_details, :refund_id
    add_index :refund_details, :payment_detail_id
    add_index :refunds, :user_id
  end
end
