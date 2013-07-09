class Judge < ActiveRecord::Base
    belongs_to :event_category
    belongs_to :judge_type
    belongs_to :user
    has_many :scores, :dependent => :destroy, :include => :competitor, :order => "competitors.position"
    has_many :boundary_scores, :dependent => :destroy, :include => :competitor, :order => "competitors.position"
    has_many :street_scores, :dependent => :destroy, :include => :competitor, :order => "competitors.position"
    has_many :standard_execution_scores, :dependent => :destroy, :include => :standard_skill_routine_entry, :order => "standard_skill_routine_entries.position"
    has_many :standard_difficulty_scores, :dependent => :destroy, :include => :standard_skill_routine_entry, :order => "standard_skill_routine_entries.position"
    has_many :competitors, :through => :event_category, :order => "position"

    accepts_nested_attributes_for :standard_execution_scores
    accepts_nested_attributes_for :standard_difficulty_scores

    attr_accessible :event_category_id, :judge_type_id, :user_id, :standard_execution_scores_attributes, :standard_difficulty_scores_attributes
    
    validates :event_category_id, :presence => true
    validates :judge_type_id, :presence => true, :uniqueness => {:scope => [:event_category_id, :user_id] }
    validates :user_id, :presence => true

    def external_id
        user.registrant_id
    end

    def name
        user.email
    end

    def to_s
        name
    end
    def get_scores
        if event_category.event.event_class.name == "Street"
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
