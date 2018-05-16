class AddAlternateOptionToMember < ActiveRecord::Migration[4.2]
  def change
    add_column :members, :alternate, :boolean, default: false, null: false
  end
end
