class Ability
  include CanCan::Ability

  def initialize(user)
    if user.present?
      define_ability_for_logged_in_user(user)
    end
    # Even Non-Logged-In Users can still:

    can :read, StandardSkillEntry
    can :logo, EventConfiguration

    if EventConfiguration.test_mode
      # allow the user to upgrade their account in TEST MODE
      can :test_mode_role, EventConfiguration
      can :fake_complete, Payment
    else
      # disable for all
      cannot :test_mode_role, EventConfiguration
      cannot :fake_complete, Payment
    end

  end

  def set_judge_abilities(user)
    can :read, Competitor
    can :judging, Event

    can :read, Judge, :user_id => user.id
    # Freestyle
    can :create, Score
    can [:read, :update, :destroy], Score do |score|
      score.try(:user) == user
    end

    # Distance
    can :manage, DistanceAttempt

    can :read, Competition
    can :create_scores, Competition do |competition|
      !competition.locked
    end
  end

  def set_chief_judge_abilities(user)
    # :read is main chief_judge menu-page
    # :results is for printing
    can [:read, :results, :sign_ups], Event do |ev|
      user.has_role? :chief_judge, ev
    end
    can :sign_ups, EventCategory do |ec|
      user.has_role? :chief_judge, ec.event
    end
    can :manage, Competitor do |comp|
      user.has_role? :chief_judge, comp.competition.try(:event)
    end

    can [:read], Score do |score|
      user.has_role? :chief_judge, score.competition.event
    end

    # so that they can create/view judges
    can [:read], Competition do |comp|
      user.has_role? :chief_judge, comp.event
    end

    can [:announcer, :heat_recording, :two_attempt_recording, :results], Competition do |comp|
      user.has_role? :chief_judge, comp.event
    end
    can [:freestyle_scores, :distance_attempts,
      :export_scores, :set_places, :lock], Competition do |comp|
      user.has_role? :chief_judge, comp.event
      end

    can :manage, Member do |member|
      user.has_role? :chief_judge, member.competitor.event
    end
    can :manage, ImportResult do |import_result|
      user.has_role? :chief_judge, import_result.competition.event
    end
    can :manage, TimeResult do |time_result|
      user.has_role? :chief_judge, time_result.competition.event
    end

    can :manage, Judge do |judge|
      user.has_role? :chief_judge, judge.competition.event
    end
  end

  def define_ability_for_logged_in_user(user)
    alias_action :create, :read, :update, :destroy, :to => :crud

    if user.has_role? :super_admin
      can :access, :rails_admin
      can :dashboard
      can :manage, :all
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
      can :manage, Judge
    end

    if user.has_role? :event_planner
      can :summary, Event
      can :sign_ups, EventCategory
    end

    if user.has_role? :race_official or user.has_role? :admin
      can :manage, LaneAssignment
    end

    # Scoring abilities
    if user.has_role? :judge
      set_judge_abilities(user)
    end

    if user.has_role? :chief_judge, :any
      set_chief_judge_abilities(user)
    end

    define_payment_ability(user)

    define_registrant_ability(user)

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

    #can :create, Song do
    #  user.has_role? :admin
    #end
    unless EventConfiguration.music_submission_ended?
      can :manage, Song do |song|
        user.registrants.include?(song.registrant)
      end
    end

    # Sharing Registrants across Users
    can :read, User, :id => user.id
    can [:read, :new, :create], AdditionalRegistrantAccess, :user_id => user.id
    can :invitations, AdditionalRegistrantAccess
    can [:decline, :accept_readonly], AdditionalRegistrantAccess do |aca|
      aca.registrant.user == user
    end
  end

  def define_payment_ability(user)
    # Payment
    can :summary, Payment if (user.has_role? :payment_admin or user.has_role? :admin)
    can :details, ExpenseItem if (user.has_role? :payment_admin or user.has_role? :admin)
    can :read, Payment if user.has_role? :admin
    can :manage, Payment if user.has_role? :super_admin
    can :read, Payment, :user_id => user.id
    unless EventConfiguration.closed?
      can [:new, :create], Payment
    end
  end

  # Registrant
  def define_registrant_ability(user)
    if user.has_role? :admin
      can :reg_fee, Registrant
      can :update_reg_fee, Registrant
      can :manage_all, Registrant
      can :email, Registrant
      can :send_email, Registrant
      can :bag_labels, Registrant
      can :undelete, Registrant
      can :crud, Registrant
      can [:index, :create, :destroy], RegistrantExpenseItem
      can [:crud, :list], Song
    end
    # not-object-specific
    can :empty_waiver, Registrant
    can :all, Registrant

    unless EventConfiguration.closed? and ENV['ONSITE_REGISTRATION'] != "true"
      can [:update, :destroy], Registrant, :user_id => user.id
      #can [:create], RegistrantExpenseItem, :user_id => user.id
      can [:index, :create, :destroy], RegistrantExpenseItem do |rei|
        (not rei.system_managed) and user.registrants.include?(rei.registrant)
      end
      can :create, Registrant # necessary because we set the user in the controller?
    end

    can :read, Registrant do |reg|
      user.accessible_registrants.include?(reg)
    end

    # :read_contact_info allows viewing the contact_info block (additional_registrant_accesess don't allow this)
    can [:waiver, :read_contact_info], Registrant, :user_id => user.id
  end
end
