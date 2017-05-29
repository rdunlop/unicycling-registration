class AddDefaultToTwoResultStatus < ActiveRecord::Migration
  def up
    execute "UPDATE two_attempt_entries SET status_1 = 'active' WHERE status_1 IS NULL"
    execute "UPDATE two_attempt_entries SET status_2 = 'active' WHERE status_2 IS NULL"
    change_column_default :two_attempt_entries, :status_1, "active"
    change_column_default :two_attempt_entries, :status_2, "active"
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
