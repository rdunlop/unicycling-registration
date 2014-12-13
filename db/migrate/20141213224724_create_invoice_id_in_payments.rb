class CreateInvoiceIdInPayments < ActiveRecord::Migration
  def up
    add_column :payments, :invoice_id, :string
    execute "UPDATE payments SET invoice_id = id"
  end

  def down
    remove_column :payments, :invoice_id
  end
end
