class AddWithdrawnAtField < ActiveRecord::Migration
  def change
    add_column :competitors, :withdrawn_at, :datetime
  end
end
