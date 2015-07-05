class MakeEnteredAtRequired < ActiveRecord::Migration
  def up
    execute "UPDATE time_results SET entered_at = created_at WHERE entered_at IS NULL"
    execute "UPDATE external_results SET entered_at = created_at WHERE entered_at IS NULL"
    change_column_null :time_results, :entered_at, false
    change_column_null :external_results, :entered_at, false
  end

  def down
    change_column_null :time_results, :entered_at, true
    change_column_null :external_results, :entered_at, true
  end
end
