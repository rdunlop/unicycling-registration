# == Schema Information
#
# Table name: scores
#
#  id            :integer          not null, primary key
#  competitor_id :integer
#  val_1         :decimal(5, 3)
#  val_2         :decimal(5, 3)
#  val_3         :decimal(5, 3)
#  val_4         :decimal(5, 3)
#  notes         :text
#  judge_id      :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class Score < ActiveRecord::Base
  include Judgeable

  def self.score_fields
    [:val_1, :val_2, :val_3, :val_4]
  end
  include JudgeScoreable
end
