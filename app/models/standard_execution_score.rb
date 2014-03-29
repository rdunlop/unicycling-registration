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
