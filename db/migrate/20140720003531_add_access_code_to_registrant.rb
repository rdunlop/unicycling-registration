class AddAccessCodeToRegistrant < ActiveRecord::Migration
  class Registrant < ActiveRecord::Base
  end

  def up
    add_column :registrants, :access_code, :string
    Registrant.reset_column_information

    Registrant.all.each do |registrant|
      registrant.update_column(:access_code, SecureRandom.hex(4))
    end
  end

  def down
    remove_column :registranst, :access_code
  end
end
