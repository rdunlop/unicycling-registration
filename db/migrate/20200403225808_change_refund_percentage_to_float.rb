class ChangeRefundPercentageToFloat < ActiveRecord::Migration[5.2]
  def up
    # up to 6 digits
    # up to 5 digits after the decimal point
    change_column :refunds, :percentage, :decimal, precision: 8, scale: 5
  end

  def down
    change_column :refunds, :percentage, :integer
  end
end
