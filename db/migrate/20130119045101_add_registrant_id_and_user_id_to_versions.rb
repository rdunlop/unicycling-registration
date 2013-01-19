class AddRegistrantIdAndUserIdToVersions < ActiveRecord::Migration
  def change
    add_column :versions, :registrant_id, :integer
    add_column :versions, :user_id, :integer
  end
end
