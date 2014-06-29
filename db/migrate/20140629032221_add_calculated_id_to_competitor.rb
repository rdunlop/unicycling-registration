class AddCalculatedIdToCompetitor < ActiveRecord::Migration
  class Competitor < ActiveRecord::Base
    has_many :members
  end

  class Registrant < ActiveRecord::Base
  end

  class Member < ActiveRecord::Base
    belongs_to :competitor
    belongs_to :registrant
  end

  def up
    add_column :competitors, :lowest_member_bib_number, :integer
    Competitor.reset_column_information
    Competitor.all.each do |competitor|
      lowest_bib_number = competitor.members.map{ |member| member.registrant.bib_number }.min
      competitor.update_attribute(:lowest_member_bib_number, lowest_bib_number)
    end
  end

  def down
    remove_column :competitors, :lowest_member_bib_number
  end
end
