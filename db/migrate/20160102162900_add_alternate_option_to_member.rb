class AddAlternateOptionToMember < ActiveRecord::Migration
  def change
    add_column :members, :alternate, :boolean, default: false, null: false
  end
end
