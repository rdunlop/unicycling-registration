# == Schema Information
#
# Table name: lane_assignments
#
#  id             :integer          not null, primary key
#  competition_id :integer
#  heat           :integer
#  lane           :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  competitor_id  :integer
#
# Indexes
#
#  index_lane_assignments_on_competition_id  (competition_id)
#

class LaneAssignment < ActiveRecord::Base
  belongs_to :competition
  belongs_to :competitor

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
