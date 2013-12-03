class StandardDifficultyScore < ActiveRecord::Base
    belongs_to :competitor
    belongs_to :judge
    belongs_to :standard_skill_routine_entry

    validates :judge_id, :presence => true, :uniqueness => {:scope => [:standard_skill_routine_entry_id, :competitor_id]}
    validates :competitor_id, :presence => true
    validates :standard_skill_routine_entry_id, :presence => true

    validates :devaluation, :presence => true, :inclusion => { :in => [0, 50, 100] }
end
