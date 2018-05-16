class AddCrankSizeToCompetitor < ActiveRecord::Migration[4.2]
  def change
    add_column :competitors, :riding_crank_size, :integer
  end
end
