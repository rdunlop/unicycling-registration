class ChangeEventInitToDefault < ActiveRecord::Migration[4.2]
  def up
    change_column :events, :visible, :boolean, null: false, default: true
    execute "UPDATE events SET visible = true WHERE visible IS NULL"
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
