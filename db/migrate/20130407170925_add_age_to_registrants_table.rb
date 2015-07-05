class AddAgeToRegistrantsTable < ActiveRecord::Migration
  class EventConfiguration < ActiveRecord::Base
  end

  class Registrant < ActiveRecord::Base
    def set_age
      start_date = EventConfiguration.first.start_date
      if start_date.nil? || birthday.nil?
        self.age = 99
      else
        if (birthday.month < start_date.month) || (birthday.month == start_date.month && birthday.day <= start_date.day)
          self.age = start_date.year - birthday.year
        else
          self.age = (start_date.year - 1) - birthday.year
        end
      end
    end
  end

  def up
    add_column :registrants, :age, :integer
    EventConfiguration.reset_column_information
    Registrant.reset_column_information
    Registrant.all.each do |reg|
      reg.set_age
      reg.save(validate: false)
    end
  end

  def down
    remove_column :registrants, :age
  end
end
