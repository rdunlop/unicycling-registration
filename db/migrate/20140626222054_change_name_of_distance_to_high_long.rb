class ChangeNameOfDistanceToHighLong < ActiveRecord::Migration
  class Competition < ActiveRecord::Base
  end

  class JudgeType < ActiveRecord::Base
  end

  def up
    Competition.reset_column_information
    Competition.where(scoring_class: "Two Attempt Distance").each do |c|
      c.update_attribute(:scoring_class,  "High/Long")
    end
    JudgeType.reset_column_information
    JudgeType.where(event_class: "Two Attempt Distance").each do |j|
      j.update_attribute(:event_class, "High/Long")
      j.update_attribute(:name, "High/Long Judge Type")
    end
  end

  def down
    Competition.reset_column_information
    Competition.where(scoring_class: "High/Long").each do |c|
      c.update_attribute(:scoring_class,  "Two Attempt Distance")
    end
    JudgeType.where(event_class: "High/Long").each do |j|
      j.update_attribute(:event_class, "Two Attempt Distance")
      j.update_attribute(:name, "Distance Judge Type")
    end
  end
end
