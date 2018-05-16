class AddPercentageToRefund < ActiveRecord::Migration[4.2]
  def change
    add_column :refunds, :percentage, :integer, default: 100
  end
end
