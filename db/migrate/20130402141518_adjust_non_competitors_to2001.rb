class AdjustNonCompetitorsTo2001 < ActiveRecord::Migration
  class Registrant < ActiveRecord::Base
  end

  def up
    Registrant.where("bib_number >= 2000").order("bib_number DESC").each do |reg|
      reg.bib_number +=1
      reg.save!
    end
  end

  def down
    Registrant.where("bib_number > 2000").order("bib_number ASC").each do |reg|
      reg.bib_number -=1
      reg.save!
    end
  end
end
