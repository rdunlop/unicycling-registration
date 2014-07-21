class AddRegistrantDroppedFlagToMember < ActiveRecord::Migration
  def change
    add_column :members, :dropped_from_registration, :boolean, default: false
  end
end
