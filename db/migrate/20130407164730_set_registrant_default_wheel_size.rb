class SetRegistrantDefaultWheelSize < ActiveRecord::Migration
  class EventConfiguration < ActiveRecord::Base
  end
  class WheelSize < ActiveRecord::Base
  end

  class Registrant < ActiveRecord::Base
    def age
      start_date = EventConfiguration.singleton.start_date
      if start_date.nil? || birthday.nil?
        99
      else
        if (birthday.month < start_date.month) || (birthday.month == start_date.month && birthday.day <= start_date.day)
          start_date.year - birthday.year
        else
          (start_date.year - 1) - birthday.year
        end
      end
    end

    def set_default_wheel_size
      if default_wheel_size.nil?
        if age > 10
          self.default_wheel_size = WheelSize.find_by(description: "24\" Wheel")
        else
          self.default_wheel_size = WheelSize.find_by(description: "20\" Wheel")
        end
      end
    end

    belongs_to :default_wheel_size, class_name: "WheelSize", foreign_key: :wheel_size_id
  end

  def up
    WheelSize.find_or_create_by(position: 1, description: "16\" Wheel")
    WheelSize.find_or_create_by(position: 2, description: "20\" Wheel")
    WheelSize.find_or_create_by(position: 3, description: "24\" Wheel")
    EventConfiguration.reset_column_information
    WheelSize.reset_column_information
    Registrant.reset_column_information
    Registrant.all.each do |reg|
      reg.set_default_wheel_size
      reg.save(validate: false)
    end
  end

  def down
    EventConfiguration.reset_column_information
    WheelSize.reset_column_information
    Registrant.reset_column_information
    Registrant.all.each do |reg|
      reg.default_wheel_size = nil
      reg.save(validate: false)
    end
  end
end
