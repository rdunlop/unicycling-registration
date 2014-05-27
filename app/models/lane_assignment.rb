# == Schema Information
#
# Table name: lane_assignments
#
#  id             :integer          not null, primary key
#  competition_id :integer
#  registrant_id  :integer
#  heat           :integer
#  lane           :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class LaneAssignment < ActiveRecord::Base
  belongs_to :competition
  belongs_to :registrant

  validates :competition_id, :registrant_id, :heat, :lane, :presence => true
  validates :heat, :uniqueness => {:scope => [:competition_id, :lane] }


  default_scope { order(:heat, :lane) }

  def status
    matching_record.try(:status)
  end

  def comments
    matching_record.try(:comments)
  end

  def matching_record
    @matching_record ||= ImportResult.where(competition: competition, bib_number: registrant_id).first
  end
end
