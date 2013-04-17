class AddPaymentNoteToPayment < ActiveRecord::Migration
  def change
    add_column :payments, :note, :string
  end
end
