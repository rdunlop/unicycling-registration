class AllowLodgingToBeIndividuallyDisabled < ActiveRecord::Migration[5.1]
  def change
    add_column :lodgings, :visible, :boolean, default: true, null: false
    add_index :lodgings, :visible
  end
end
