class ChangeStatusOfTimeResultFromNilToActive < ActiveRecord::Migration
  def up
    execute "UPDATE time_results SET status = 'active' WHERE status IS NULL"
    change_column_null :time_results, :status, false
  end

  def down
    change_column_null :time_results, :status, true
    execute "UPDATE time_results SET status = NULL WHERE status = 'active'"
  end
end
