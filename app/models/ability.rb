class Ability
  include CanCan::Ability

  def initialize(user)
    if user.nil?
    else
      if user.has_role? :super_admin
        can :access, :rails_admin
        can :dashboard
        can :manage, :all
        can :all, StandardSkillRoutine
        return # required in order to allow rails_admin to function
      end

      # Competitor Assignment
      if user.has_role? :admin
        can :manage, Competitor
      elsif user.has_role? :judge
        can :read, Competitor
      end

      # Scoring abilities
      if user.has_role? :judge
        can :read, EventCategory
        can :create_scores, EventCategory do |event_category|
          !event_category.locked
        end

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
      EventCategory.all.each do |ev|
        if user.has_role?(:chief_judge, ev)
          can :administer, EventCategory
        end
      end

      # score Summaries
      can :freestyle_scores, EventCategory do |ev|
        user.has_role?(:chief_judge, ev)
      end
      can :distance_attempts, EventCategory do |ev|
        user.has_role?(:chief_judge, ev)
      end

      # Payment
      can :manage, Payment if user.has_role? :admin or user.has_role? :super_admin
      can :read, Payment, :user_id => user.id
      unless EventConfiguration.closed?
        can [:new, :create], Payment
      end

      # Registrant
      can :manage, Registrant if user.has_role? :admin or user.has_role? :super_admin
      can [:all, :waiver], Registrant, :user_id => user.id

      unless EventConfiguration.closed?
        can [:update, :items, :update_items, :destroy], Registrant, :user_id => user.id
        can :create, Registrant # necessary because we set the user in the controller?
        can :new_noncompetitor, Registrant # necessary because we set the user in the controller?
      end

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
