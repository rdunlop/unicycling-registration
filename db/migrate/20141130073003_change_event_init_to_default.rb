class ChangeEventInitToDefault < ActiveRecord::Migration
  def change
    change_column :events, :visible, :boolean, null: false, default: true
    execute "UPDATE events SET visible = true WHERE visible IS NULL"
  end
end
