class Ability
  include CanCan::Ability

  def initialize(user)
    if user.nil?
    else
      alias_action :create, :read, :update, :destroy, :to => :crud

      if user.has_role? :super_admin
        can :access, :rails_admin
        can :dashboard
        can :manage, StandardSkillEntry # written for clarity, though :all includes this
        can :manage, StandardSkillRoutine # written for clarity, though :all includes this
        can :manage, :all
        can :all, StandardSkillRoutine
        return # required in order to allow rails_admin to function
      end

      # Competitor Assignment
      if user.has_role? :admin
        can :summary, Event
        can :sign_ups, EventCategory
        can :manage, AgeGroupType
        can :manage, AgeGroupEntry
        can :manage, Competitor
        can :manage, ImportResult
        can :manage, AwardLabel
        can :manage, ExternalResult
        can :manage, RegistrantGroup
        can :reg_fee, Registrant
        can :update_reg_fee, Registrant
        can :manage_all, Registrant
        can :email, Registrant
        can :send_email, Registrant
        can :bag_labels, Registrant
        can :undelete, Registrant
      elsif user.has_role? :judge
        can :read, Competitor
      end

      if user.has_role? :race_official or user.has_role? :admin #XXX (add race_official)
        can :manage, LaneAssignment
      end

      # Scoring abilities
      if user.has_role? :judge
        can :judging, Event
        can :read, Competition
        can :create_scores, Competition do |competition|
          !competition.locked
        end

        can :read, Judge, :user_id => user.id
        # Freestyle
        can :create, Score
        can [:read, :update], Score do |score|
          score.try(:user) == user
        end

        # Distance
        can :manage, DistanceAttempt

        # Street
        can :create, StreetScore
        can [:read, :update, :destroy], StreetScore do |score|
          score.try(:user) == user
        end
      end

      if user.has_role? :chief_judge, :any
        can :freestyle, Event
        can :sign_ups, EventCategory do |ec|
          user.has_role? :chief_judge, ec.event
        end
        can :manage, Competitor do |comp|
          user.has_role? :chief_judge, comp.competition.try(:event)
        end
        can :manage, Competition do |comp|
          user.has_role? :chief_judge, comp.event
        end
      end

      if user.has_role? :chief_judge, :any or user.has_role? :admin
        can :manage, Judge
      end

      # score Summaries
      can :freestyle_scores, Competition do |ev|
        user.has_role?(:chief_judge, ev)
      end
      can :distance_attempts, Competition do |ev|
        user.has_role?(:chief_judge, ev)
      end

      # Payment
      can :read, Payment if user.has_role? :admin
      can :manage, Payment if user.has_role? :super_admin
      can :read, Payment, :user_id => user.id
      unless EventConfiguration.closed?
        can [:new, :create], Payment
      end

      # Registrant
      can :empty_waiver, Registrant
      can :crud, Registrant if user.has_role? :admin or user.has_role? :super_admin
      can :items, Registrant if user.has_role? :admin or user.has_role? :super_admin
      can [:all, :waiver], Registrant, :user_id => user.id

      unless EventConfiguration.closed? and ENV['ONSITE_REGISTRATION'] != "true"
        can [:update, :items, :destroy], Registrant, :user_id => user.id
        #can [:create], RegistrantExpenseItem, :user_id => user.id
        can [:create, :destroy], RegistrantExpenseItem do |rei|
          (not rei.system_managed) and user.registrants.include?(rei.registrant)
        end
        can :create, Registrant # necessary because we set the user in the controller?
        can :new_noncompetitor, Registrant # necessary because we set the user in the controller?
      end
      can [:create, :destroy], RegistrantExpenseItem if user.has_role? :admin or user.has_role? :super_admin

      # Standard Skill Routines
      if user.has_role? :admin
        can :manage, StandardSkillRoutineEntry
        can :manage, StandardSkillRoutine
      end
      unless EventConfiguration.standard_skill_closed?
        can [:read, :create, :destroy], StandardSkillRoutine do |routine|
          user.registrants.include?(routine.registrant)
        end
        can :create, StandardSkillRoutine # necessary because we set the registrant in the controller?
        can :manage, StandardSkillRoutineEntry do |entry|
          can? :destroy, entry.standard_skill_routine
        end
      end

      # Sharing Registrants across Users
      can :read, User, :id => user.id
      can [:read, :new, :create], AdditionalRegistrantAccess, :user_id => user.id
      can :invitations, AdditionalRegistrantAccess
      can [:decline, :accept_readonly], AdditionalRegistrantAccess do |aca|
        aca.registrant.user == user
      end
      can :read, Registrant do |reg|
        user.accessible_registrants.include? (reg)
      end
      # allow viewing the contact_info block (additional_registrant_accesess don't allow this)
      can :read_contact_info, Registrant, :user_id => user.id
    end

    # Even Non-Logged-In Users can still:

    can :read, StandardSkillEntry
    can :logo, EventConfiguration

    # allow the user to upgrade their account in TEST MODE
    @config = EventConfiguration.first
    if @config.nil?
      @config = EventConfiguration.new
    end

    # disable for all
    cannot :admin, EventConfiguration
    cannot :super_admin, EventConfiguration
    cannot :normal, EventConfiguration
    cannot :fake_complete, Payment
    if @config.test_mode
      can :admin, EventConfiguration
      can :super_admin, EventConfiguration
      can :normal, EventConfiguration
      can :fake_complete, Payment
    end

    # Define abilities for the passed in user here. For example:
    #
    #   user ||= User.new # guest user (not logged in)
    #   if user.admin?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end
    #
    # The first argument to `can` is the action you are giving the user permission to do.
    # If you pass :manage it will apply to every action. Other common actions here are
    # :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on. If you pass
    # :all it will apply to every resource. Otherwise pass a Ruby class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details: https://github.com/ryanb/cancan/wiki/Defining-Abilities
  end
end
