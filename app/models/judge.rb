class Judge < ActiveRecord::Base
    belongs_to :competition
    belongs_to :judge_type
    belongs_to :user

    before_destroy :check_for_scores # must occur before the dependent->destroy

    has_many :scores, -> {order("competitors.position").includes(:competitor) }, :dependent => :destroy
    has_many :boundary_scores, -> {order("competitors.position").includes(:competitor) }, :dependent => :destroy
    has_many :street_scores, -> {order("competitors.position").includes(:competitor)}, :dependent => :destroy
    has_many :standard_execution_scores, -> {order("standard_skill_routine_entries.position").includes(:standard_skill_routine_entry)}, :dependent => :destroy
    has_many :standard_difficulty_scores, -> {order("standard_skill_routine_entries.position").includes(:standard_skill_routine_entry)}, :dependent => :destroy
    has_many :competitors, -> {order "position"}, :through => :competition

    accepts_nested_attributes_for :standard_execution_scores
    accepts_nested_attributes_for :standard_difficulty_scores

    validates :competition_id, :presence => true
    validates :judge_type_id, :presence => true, :uniqueness => {:scope => [:competition_id, :user_id] }
    validates :user_id, :presence => true

    delegate :event, to: :competition

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
        user.to_s
    end

    def to_s
        name + "(" + judge_type.to_s + ")"
    end

    def get_scores
        if competition.event_class == "Street"
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
