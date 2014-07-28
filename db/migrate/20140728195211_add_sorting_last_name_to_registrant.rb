class AddSortingLastNameToRegistrant < ActiveRecord::Migration
  class Registrant < ActiveRecord::Base
  end

  def up
    add_column :registrants, :sorted_last_name, :string
    Registrant.reset_column_information

    Registrant.all.each do |reg|
      reg.update_column(:sorted_last_name, ActiveSupport::Inflector.transliterate(reg.last_name).downcase)
    end
  end

  def down
    remove_column :registrants, :sorted_last_name
  end
end
