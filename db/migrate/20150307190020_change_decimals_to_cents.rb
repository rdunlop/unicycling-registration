class ChangeDecimalsToCents < ActiveRecord::Migration
  def up
    add_column :coupon_codes, :price_cents, :integer
    execute "UPDATE coupon_codes SET price_cents = (price * 100)"
    remove_column :coupon_codes, :price

    add_column :expense_items, :cost_cents, :integer
    execute "UPDATE expense_items SET cost_cents = (cost * 100)"
    remove_column :expense_items, :cost

    # Changes from tax_percentage to an actual amount
    add_column :expense_items, :tax_cents, :integer
    execute "UPDATE expense_items SET tax_cents = ceil((tax_percentage / 100.0) * cost_cents)"
    remove_column :expense_items, :tax_percentage

    add_column :payment_details, :amount_cents, :integer
    execute "UPDATE payment_details SET amount_cents = (amount * 100)"
    remove_column :payment_details, :amount

    add_column :registrant_expense_items, :custom_cost_cents, :integer
    execute "UPDATE registrant_expense_items SET custom_cost_cents = (custom_cost * 100)"
    remove_column :registrant_expense_items, :custom_cost
  end

  def down
    add_column :registrant_expense_items, :custom_cost, :decimal
    execute "UPDATE registrant_expense_items SET custom_cost = (custom_cost_cents / 100.0)"
    remove_column :registrant_expense_items, :custom_cost_cents

    add_column :payment_details, :amount, :decimal
    execute "UPDATE payment_details SET amount = (amount_cents / 100.0)"
    remove_column :payment_details, :amount_cents

    # Changes from tax_cents to tax_percentage
    add_column :expense_items, :tax_percentage, :decimal, precision: 5, scale: 3, default: 0.0
    execute "UPDATE expense_items SET tax_percentage = (((tax_cents * 1.0) /cost_cents) * 100.0) WHERE tax_cents != 0"
    remove_column :expense_items, :tax_cents

    add_column :expense_items, :cost, :decimal
    execute "UPDATE expense_items SET cost = (cost_cents / 100.0)"
    remove_column :expense_items, :cost_cents

    add_column :coupon_codes, :price, :decimal
    execute "UPDATE coupon_codes SET price = (price_cents / 100.0)"
    remove_column :coupon_codes, :price_cents
  end
end
