class ChangePreliminaryToBoolean < ActiveRecord::Migration
  def up
    add_column :time_results, :preliminary, :boolean

    add_column :external_results, :preliminary, :boolean
    execute "UPDATE external_results SET preliminary = TRUE WHERE status = 'preliminary'"
    change_column_null :external_results, :preliminary, false, false
  end

  def down
    remove_column :time_results, :preliminary

    execute "UPDATE external_results SET status = 'preliminary' WHERE preliminary = TRUE"
    remove_column :external_results, :preliminary
  end
end
