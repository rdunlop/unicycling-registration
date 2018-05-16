class RemoveNormalFromUser < ActiveRecord::Migration[4.2]
  def up
    remove_column :users, :normal
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
