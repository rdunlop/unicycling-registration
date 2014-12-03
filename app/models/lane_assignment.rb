# == Schema Information
#
# Table name: lane_assignments
#
#  id             :integer          not null, primary key
#  competition_id :integer
#  heat           :integer
#  lane           :integer
#  created_at     :datetime
#  updated_at     :datetime
#  competitor_id  :integer
#
# Indexes
#
#  index_lane_assignments_on_competition_id                    (competition_id)
#  index_lane_assignments_on_competition_id_and_heat_and_lane  (competition_id,heat,lane) UNIQUE
#

class LaneAssignment < ActiveRecord::Base
  belongs_to :competition
  belongs_to :competitor, touch: true
  include CompetitorAutoCreation

  validates :competition, :competitor, :heat, :lane, :presence => true
  validates :heat, :uniqueness => {:scope => [:competition_id, :lane] }

  default_scope { order(:heat, :lane) }

  def status
    matching_record.try(:status)
  end

  def comments
    matching_record.try(:comments)
  end

  def matching_record
    @matching_record ||= ImportResult.where(competition: competition, bib_number: competitor.first_bib_number).first
  end
end
