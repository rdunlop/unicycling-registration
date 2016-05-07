class AddMissingUniquenessValidations < ActiveRecord::Migration
  def change
    reversible do |direction|
      direction.up do
        remove_index :standard_skill_scores, [:judge_id, :competitor_id]
        add_index :standard_skill_scores, [:judge_id, :competitor_id], unique: true

        remove_index :expense_items, [:cost_element_type, :cost_element_id]
        add_index :expense_items, [:cost_element_type, :cost_element_id], unique: true

        remove_index :payment_detail_coupon_codes, :payment_detail_id
        add_index :payment_detail_coupon_codes, :payment_detail_id, unique: true
      end
      direction.down do
        remove_index :standard_skill_scores, [:judge_id, :competitor_id]
        add_index :standard_skill_scores, [:judge_id, :competitor_id]

        remove_index :expense_items, [:cost_element_type, :cost_element_id]
        add_index :expense_items, [:cost_element_type, :cost_element_id]

        remove_index :payment_detail_coupon_codes, :payment_detail_id
        add_index :payment_detail_coupon_codes, :payment_detail_id
      end
    end

    add_index :time_results, :heat_lane_result_id, unique: true
    add_index :coupon_codes, :code, unique: true
  end
end
