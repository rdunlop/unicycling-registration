# == Schema Information
#
# Table name: street_scores
#
#  id            :integer          not null, primary key
#  competitor_id :integer
#  judge_id      :integer
#  val_1         :decimal(5, 3)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class StreetScore < ActiveRecord::Base
  include Judgeable

  def self.score_fields
    [:val_1]
  end
  include JudgeScoreable
end
