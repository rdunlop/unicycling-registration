class AddAwardedBooleanToCompetition < ActiveRecord::Migration
  def change
    add_column :competitions, :awarded, :boolean, default: false
  end
end
