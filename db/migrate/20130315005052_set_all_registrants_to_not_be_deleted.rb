class SetAllRegistrantsToNotBeDeleted < ActiveRecord::Migration
  class Registrant < ActiveRecord::Base
  end

  def up
    Registrant.reset_column_information
    Registrant.all.each do |reg|
      reg.deleted = false
      reg.save
    end
  end

  def down
  end
end
