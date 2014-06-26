class ChangeNameOfDistanceToHighLong < ActiveRecord::Migration
  class Competition < ActiveRecord::Base
  end
  def change
    Competition.reset_column_information
    Competition.each do |c|
      if c.scoring_class == "Two Attempt Distance"
        c.update_attribute(:scoring_class,  "High/Long")
      end
    end
  end
end
