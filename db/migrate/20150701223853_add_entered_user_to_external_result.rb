class AddEnteredUserToExternalResult < ActiveRecord::Migration
  class User < ActiveRecord::Base
    rolify
  end

  def up
    add_column :external_results, :entered_by_id, :integer
    add_column :external_results, :entered_at, :datetime
    add_column :external_results, :status, :string
    change_column_null :external_results, :status, false, "active"
    results = execute("select ur.user_id from users_roles ur, roles r where ur.role_id = r.id AND r.name='super_admin'")
    super_user_id = results.count > 0 ? results[0]["user_id"] : nil
    change_column_null :external_results, :entered_by_id, false, super_user_id

    add_column :time_results, :entered_by_id, :integer
    change_column_null :time_results, :entered_by_id, false, super_user_id
  end

  def down
    remove_column :external_results, :entered_by_id
    remove_column :external_results, :entered_at
    remove_column :external_results, :status

    remove_column :time_results, :entered_by_id
  end
end
