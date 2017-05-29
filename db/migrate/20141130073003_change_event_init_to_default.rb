class ChangeEventInitToDefault < ActiveRecord::Migration
  def up
    change_column :events, :visible, :boolean, null: false, default: true
    execute "UPDATE events SET visible = true WHERE visible IS NULL"
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
