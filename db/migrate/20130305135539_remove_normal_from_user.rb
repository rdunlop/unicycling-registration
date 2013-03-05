class RemoveNormalFromUser < ActiveRecord::Migration
  def change
    remove_column :users, :normal
  end
end
