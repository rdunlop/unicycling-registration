class AddRegPaidToRegistrant < ActiveRecord::Migration[5.0]
  def change
    add_column :registrants, :paid, :boolean, null: false, default: false
  end
end
