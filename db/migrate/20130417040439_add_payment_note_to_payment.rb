class AddPaymentNoteToPayment < ActiveRecord::Migration[4.2]
  def change
    add_column :payments, :note, :string
  end
end
