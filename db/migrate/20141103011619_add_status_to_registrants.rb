class AddStatusToRegistrants < ActiveRecord::Migration
  def change
    add_column :registrants, :status, :string, null: false, default: "active"
  end
end
