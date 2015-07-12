class Ability
  include CanCan::Ability

  attr_accessor :allow_reg_modifications

  def config
    @config ||= EventConfiguration.singleton
  end

  def reg_closed?
    EventConfiguration.closed? && !allow_reg_modifications
  end

  def initialize(user, allow_reg_modifications = false)
    @allow_reg_modifications = allow_reg_modifications

    if user.present?
      define_ability_for_logged_in_user(user)
    end
    # Even Non-Logged-In Users can still:

    can :read, StandardSkillEntry
    can :read, AgeGroupType
    can :show, PublishedAgeGroupEntry do |entry|
      entry.published_at.present?
    end
  end

  def set_data_entry_volunteer_abilities(user)
    can :data_entry_menu, :welcome

    can :read, Judge, user_id: user.id

    # Freestyle
    can :create, Score
    can [:read, :update, :destroy], Score do |score|
      score.try(:user) == user && !score.competitor.competition.locked?
    end

    # printing forms:
    can [:announcer, :heat_recording, :single_attempt_recording, :two_attempt_recording], Competition

    # data entry
    can :manage, ImportResult do |import_result|
      !import_result.competition.locked?
    end
    cannot [:approve, :approve_heat], ImportResult

    can :create_preliminary_result, Competition do |competition|
      competition.unlocked?
    end

    can :manage, TwoAttemptEntry do |two_attempt_entry|
      !two_attempt_entry.competition.locked?
    end

    # High/Long Data Entry
    can :manage, DistanceAttempt
    can :manage, TieBreakAdjustment
  end

  def director_and_unlocked(user, competition)
    !competition.locked? && user.has_role?(:director, competition.try(:event))
  end

  def director_or_competition_admin?(user, competition)
    user.has_role?(:director, competition.try(:event)) || user.has_role?(:competition_admin)
  end

  def set_director_abilities(user)
    set_data_entry_volunteer_abilities(user)


    # Volunteer Abilities

    can :manage, DataEntryVolunteer

    # Judging/Scoring Abilities

    can [:read], Score do |score|
      user.has_role? :director, score.competition.event
    end

    can [:results], Event do |ev|
      user.has_role? :director, ev
    end


    can [:read, :toggle_status], Judge do |judge|
      user.has_role? :director, judge.competition.try(:event)
    end

    can [:crud, :copy_judges], Judge do |judge|
      # Only allow creating judges when there are no scores yet entered
      (judge.scores.count == 0) && (director_and_unlocked(user, judge.competition))
    end

    # Data Management
    can :manage, ImportResult do |import_result|
      director_and_unlocked(user, import_result.competition)
    end

    can :manage, TimeResult do |time_result|
      director_and_unlocked(user, time_result.competition)
    end

    can :manage, WaveTime do |wave_time|
      director_and_unlocked(user, wave_time.competition)
    end

  end

  # #################################################
  # Begin new role definitions
  # #################################################

  def define_competition_admin_roles(user)
    if user.has_role? :competition_admin
      can [:crud], AgeGroupType
    end
  end

  def define_volunteer_roles(user)

    if user.has_role?(:race_official, :any) || user.has_role?(:admin)
      can :download_competitors_for_timers, :export
    end

    # Start Line Volunteer
    # End Line Volunteer
  end

  def define_ability_for_logged_in_user(user)
    alias_action :create, :read, :update, :destroy, to: :crud

    if user.has_role? :super_admin
      can :access, :rails_admin
      can :dashboard
      can :manage, :all
      return # required in order to allow rails_admin to function
    end

    define_competition_admin_roles(user)
    define_volunteer_roles(user)

    # #################################################
    # End new role definitions
    # #################################################

    # Competitor Assignment
    if user.has_role? :admin
      set_data_entry_volunteer_abilities(user)
      can [:results], Event
      can :manage, Member
      can :manage, ImportResult
      can :manage, TimeResult
      can :manage, ExternalResult
      can :manage, RegistrantGroup
      can :manage, Judge
      can :read, VolunteerOpportunity
    end

    # Scoring abilities
    if user.has_role? :data_entry_volunteer
      set_data_entry_volunteer_abilities(user)
    end

    if user.has_role? :director, :any
      set_director_abilities(user)
    end

    # Standard Skill Routines
    if user.has_role? :admin
      can :manage, StandardSkillRoutineEntry
      can :manage, StandardSkillRoutine
    end
    unless config.standard_skill_closed?
      can [:read, :create, :destroy], StandardSkillRoutine do |routine|
        user.registrants.include?(routine.registrant)
      end
      can :create, StandardSkillRoutine # necessary because we set the registrant in the controller?
      can :manage, StandardSkillRoutineEntry do |entry|
        can? :destroy, entry.standard_skill_routine
      end
    end

    # Sharing Registrants across Users
    can :read, User, id: user.id
    can [:read, :new, :create], AdditionalRegistrantAccess, user_id: user.id
    can :invitations, AdditionalRegistrantAccess
    can [:decline, :accept_readonly], AdditionalRegistrantAccess do |aca|
      aca.registrant.user == user
    end
  end
end
