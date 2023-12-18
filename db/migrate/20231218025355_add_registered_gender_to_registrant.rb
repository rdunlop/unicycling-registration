class AddRegisteredGenderToRegistrant < ActiveRecord::Migration[7.0]
  def change
    add_column :registrants, :registered_gender, :string
    reversible do |direction|
      direction.up do
        execute "UPDATE registrants SET registered_gender = gender"
      end
    end
  end
end
