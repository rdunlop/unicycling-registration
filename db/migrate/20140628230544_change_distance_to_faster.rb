class ChangeDistanceToFaster < ActiveRecord::Migration
  class Competition < ActiveRecord::Base
  end

  def up
    Competition.all.each do |comp|
      if comp.scoring_class == "Distance"
        comp.update_attribute(:scoring_class, "Shortest Time")
      end
    end
  end

  def down
    Competition.all.each do |comp|
      if comp.scoring_class == "Shortest Time"
        comp.update_attribute(:scoring_class, "Distance")
      end
    end
  end
end
