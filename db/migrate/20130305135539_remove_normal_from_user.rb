class RemoveNormalFromUser < ActiveRecord::Migration
  def up
    remove_column :users, :normal
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
