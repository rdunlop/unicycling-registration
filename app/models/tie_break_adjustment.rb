# == Schema Information
#
# Table name: tie_break_adjustments
#
#  id              :integer          not null, primary key
#  tie_break_place :integer
#  judge_id        :integer
#  competitor_id   :integer
#  created_at      :datetime
#  updated_at      :datetime
#
# Indexes
#
#  index_tie_break_adjustments_competitor_id  (competitor_id)
#  index_tie_break_adjustments_judge_id       (judge_id)
#

class TieBreakAdjustment < ActiveRecord::Base
  include Competeable

  belongs_to :judge

  validates :judge_id,      :presence => true
  validates :tie_break_place,      :presence => true, :numericality => {:greater_than_or_equal_to => 0, :less_than => 1000}

  # validate uniqueness of this competitor having a tie break adjustment

end
