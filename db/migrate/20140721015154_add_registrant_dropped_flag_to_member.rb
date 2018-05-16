class AddRegistrantDroppedFlagToMember < ActiveRecord::Migration[4.2]
  def change
    add_column :members, :dropped_from_registration, :boolean, default: false
  end
end
