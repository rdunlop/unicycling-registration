class ChangeLaneAssignmentFromRegistrantIdToCompetitorId < ActiveRecord::Migration
  class Competition < ActiveRecord::Base
    has_many :lane_assignments, :dependent => :destroy
    has_many :competitors

    def create_competitor_from_registrants(registrants, name)
      competitor = competitors.build
      competitor.position = competitors.count + 1
      competitor.custom_name = name
      registrants.each do |reg|
        member = competitor.members.build
        member.registrant = reg
      end
      competitor.save!
      competitor
    end
  end

  class Member < ActiveRecord::Base
    belongs_to :registrant
  end

  class Competitor < ActiveRecord::Base
    has_many :members
  end

  class LaneAssignment < ActiveRecord::Base
    belongs_to :competition
    belongs_to :competitor
  end

  def up
    add_column :lane_assignments, :competitor_id, :integer

    LaneAssignment.reset_column_information

    LaneAssignment.all.each do |lane_assignment|
      # Each lane assignment will have a registrant_id,
      # The competitor with this registrant_id may not exist, if so, create the competitor
      old_reg_id = lane_assignment.registrant_id
      new_comp = lane_assignment.competition.competitors.includes(:members).where(members: {registrant_id: old_reg_id}).first
      new_comp = lane_assignment.competition.create_competitor_from_registrants([Registrant.find(old_reg_id)],nil) if new_comp.nil?
      lane_assignment.update_attribute(:competitor_id, new_comp.id)
    end

    remove_column :lane_assignments, :registrant_id
  end

  def down
    add_column :lane_assignments, :registrant_id, :integer

    LaneAssignment.reset_column_information

    LaneAssignment.all.each do |lane_assignment|
      # all competitors must have valid registrants
      old_reg_id = lane_assignment.competitor.members.first.registrant_id
      lane_assignment.update_attribute(:registrant_id, old_reg_id)
    end

    remove_column :lane_assignments, :competitor_id
  end
end
