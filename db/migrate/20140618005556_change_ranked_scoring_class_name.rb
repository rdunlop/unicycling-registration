class ChangeRankedScoringClassName < ActiveRecord::Migration
  class Competition < ActiveRecord::Base
  end

  def up
    Competition.all.each do |comp|
      if comp.scoring_class == "Ranked"
        comp.update_attribute(:scoring_class, "Points Low to High")
      end
    end
  end

  def down
    Competition.all.each do |comp|
      if comp.scoring_class == "Points Low to High"
        comp.update_attribute(:scoring_class, "Ranked")
      end
    end
  end
end
