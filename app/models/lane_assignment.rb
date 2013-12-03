class LaneAssignment < ActiveRecord::Base
  belongs_to :competition
  belongs_to :registrant

  validates :competition_id, :registrant_id, :heat, :lane, :presence => true
  validates :heat, :uniqueness => {:scope => [:competition_id, :lane] }


  default_scope order(:heat, :lane)
end
