class ChangeNameOfDistanceToHighLong < ActiveRecord::Migration
  class Competition < ActiveRecord::Base
  end

  def up
    Competition.reset_column_information
    Competition.all.each do |c|
      if c.scoring_class == "Two Attempt Distance"
        c.update_attribute(:scoring_class,  "High/Long")
      end
    end
  end

  def down
    Competition.reset_column_information
    Competition.all.each do |c|
      if c.scoring_class == "High/Long"
        c.update_attribute(:scoring_class,  "Two Attempt Distance")
      end
    end
  end
end
