class Judge < ActiveRecord::Base
    include ActiveModel::ForbiddenAttributesProtection
    belongs_to :competition
    belongs_to :judge_type
    belongs_to :user

    before_destroy :check_for_scores # must occur before the dependent->destroy

    has_many :scores, :dependent => :destroy, :include => :competitor, :order => "competitors.position"
    has_many :boundary_scores, :dependent => :destroy, :include => :competitor, :order => "competitors.position"
    has_many :street_scores, :dependent => :destroy, :include => :competitor, :order => "competitors.position"
    has_many :standard_execution_scores, :dependent => :destroy, :include => :standard_skill_routine_entry, :order => "standard_skill_routine_entries.position"
    has_many :standard_difficulty_scores, :dependent => :destroy, :include => :standard_skill_routine_entry, :order => "standard_skill_routine_entries.position"
    has_many :competitors, :through => :competition, :order => "position"

    accepts_nested_attributes_for :standard_execution_scores
    accepts_nested_attributes_for :standard_difficulty_scores

    attr_accessible :competition_id, :judge_type_id, :user_id, :standard_execution_scores_attributes, :standard_difficulty_scores_attributes
    
    validates :competition_id, :presence => true
    validates :judge_type_id, :presence => true, :uniqueness => {:scope => [:competition_id, :user_id] }
    validates :user_id, :presence => true


    def check_for_scores
      if scores.count > 0
        errors[:base] << "cannot delete judge containing a score"
        return false
      end
    end

    def external_id
        user.registrant_id
    end

    def name
        user.email
    end

    def event
      competition.event
    end

    def to_s
        name
    end
    def get_scores
        if competition.event.event_class == "Street"
            self.street_scores
        else
            self.scores
        end
    end

    # retrieve my judged score for the given competitor
    def get_score(competitor)
        scores.where(:competitor_id => competitor.id).first
    end
end
