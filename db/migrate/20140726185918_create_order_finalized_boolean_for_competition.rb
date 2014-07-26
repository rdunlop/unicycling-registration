class CreateOrderFinalizedBooleanForCompetition < ActiveRecord::Migration
  def change
    add_column :competitions, :order_finalized, :boolean, default: false
  end
end
