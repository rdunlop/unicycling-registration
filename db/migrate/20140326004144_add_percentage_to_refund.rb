class AddPercentageToRefund < ActiveRecord::Migration
  def change
    add_column :refunds, :percentage, :integer, default: 100
  end
end
