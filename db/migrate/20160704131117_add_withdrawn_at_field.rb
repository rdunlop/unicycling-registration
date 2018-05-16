class AddWithdrawnAtField < ActiveRecord::Migration[4.2]
  def change
    add_column :competitors, :withdrawn_at, :datetime
  end
end
