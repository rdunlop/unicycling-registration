class ChangeCompetitionDataRecording < ActiveRecord::Migration
  class Competition < ActiveRecord::Base
  end

  def up
    Competition.reset_column_information

    Competition.all.each do |comp|
      comp.start_data_type = convert_value(comp.start_data_type)
      comp.end_data_type = convert_value(comp.end_data_type)
      comp.save!
    end
  end

  def down
    Competition.reset_column_information

    Competition.all.each do |comp|
      comp.start_data_type = unconvert_value(comp.start_data_type)
      comp.end_data_type = unconvert_value(comp.end_data_type)
      comp.save!
    end
  end

  def convert_value(value)
    case value
    when "Two Attempt Distance"
      "Two Data Per Line"
    when "Single Attempt"
      "One Data Per Line"
    else
      value
    end
  end
  def unconvert_value(value)
    case value
    when "Two Data Per Line"
      "Two Attempt Distance"
    when "One Data Per Line"
      "Single Attempt"
    else
      value
    end
  end
end
