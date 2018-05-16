class CreateOrderFinalizedBooleanForCompetition < ActiveRecord::Migration[4.2]
  def change
    add_column :competitions, :order_finalized, :boolean, default: false
  end
end
