class AddCrankSizeToCompetitor < ActiveRecord::Migration
  def change
    add_column :competitors, :riding_crank_size, :integer
  end
end
