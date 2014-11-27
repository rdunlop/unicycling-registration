# == Schema Information
#
# Table name: standard_execution_scores
#
#  id                              :integer          not null, primary key
#  competitor_id                   :integer
#  standard_skill_routine_entry_id :integer
#  judge_id                        :integer
#  wave                            :integer
#  line                            :integer
#  cross                           :integer
#  circle                          :integer
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#
# Indexes
#
#  standard_exec_judge_routine_comp  (judge_id,standard_skill_routine_entry_id,competitor_id) UNIQUE
#

class StandardExecutionScore < ActiveRecord::Base
  include Competeable
    belongs_to :judge
    belongs_to :standard_skill_routine_entry

    validates :judge_id, :presence => true, :uniqueness => {:scope => [:standard_skill_routine_entry_id, :competitor_id]}
    validates :standard_skill_routine_entry_id, :presence => true

    validates :wave, :presence => true, :numericality => {:greater_than_or_equal_to => 0}
    validates :line, :presence => true, :numericality => {:greater_than_or_equal_to => 0}
    validates :cross, :presence => true, :numericality => {:greater_than_or_equal_to => 0}
    validates :circle, :presence => true, :numericality => {:greater_than_or_equal_to => 0}

end
