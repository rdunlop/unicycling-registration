class LaneAssignment < ActiveRecord::Base
  attr_accessible :registrant_id, :competition_id, :heat, :lane

  belongs_to :competition
  belongs_to :registrant

  validates :competition_id, :registrant_id, :heat, :lane, :presence => true
end
