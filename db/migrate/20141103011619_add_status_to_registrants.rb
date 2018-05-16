class AddStatusToRegistrants < ActiveRecord::Migration[4.2]
  def change
    add_column :registrants, :status, :string, null: false, default: "active"
  end
end
