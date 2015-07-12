class Ability
  include CanCan::Ability

  attr_accessor :allow_reg_modifications

  def config
    @config ||= EventConfiguration.singleton
  end

  def reg_closed?
    EventConfiguration.closed? && !allow_reg_modifications
  end

  def artistic_reg_closed?
    reg_closed? || config.artistic_closed?
  end

  def event_sign_up_closed?
    reg_closed? || config.event_sign_up_closed?
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

    can [:read], Competitor
    can :read, Competition

    can :read, Judge, user_id: user.id

    # Freestyle
    can :create, Score
    can [:read, :update, :destroy], Score do |score|
      score.try(:user) == user && !score.competitor.competition.locked?
    end

    can [:create_scores], Competition do |competition|
      !competition.locked?
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

    # Abilities to be able to read data about a competition
    can :read, Competition do |competition|
      user.has_role?(:director, competition.event) || user.has_role?(:competition_admin)
    end

    # SignUp/Competitor management abilities
    can [:sign_ups], Event do |ev|
      user.has_role? :director, ev || user.has_role?(:competition_admin)
    end

    can :sign_ups, EventCategory
    #     #this is the way recommended by rolify...but it must not be called with the class (ie: do not call "can? :results, Event")
    #     can [:read, :results, :sign_ups], Event, id: Event.with_role(:director, user).pluck(:id)

    # Abilities to be able to change data about a competition
    can [:manage, :update_row_order], Competitor do |comp|
      comp.competition.unlocked? && (director_or_competition_admin?(user, comp.competition))
    end

    can :manage, Member do |member|
      member.competitor.competition.unlocked? && (director_or_competition_admin?(user, member.competitor.competition))
    end

    can [:set_sort, :toggle_final_sort, :sort_random, :lock], Competition do |comp|
      comp.unlocked? && (director_or_competition_admin?(user, comp))
    end

    # Volunteer Abilities

    can [:summary, :general_volunteers, :specific_volunteers], Event

    can :manage, DataEntryVolunteer

    # Judging/Scoring Abilities

    can [:read], Score do |score|
      user.has_role? :director, score.competition.event
    end

    can [:export_scores, :results, :result], Competition do |comp|
      user.has_role? :director, comp.event
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

  def define_payment_admin_roles(user)
    if user.has_role? :payment_admin
      # Allow adding items which only admins can add
      can :admin_view, ExpenseItem
      can :details, ExpenseItem
    end
  end

  def define_membership_admin_roles(user)
    if user.has_role?(:membership_admin) && config.usa_membership_config?
      can :manage, :usa_membership
    end
  end

  def define_event_planner_roles(user)
    if user.has_role? :event_planner
      can [:summary, :general_volunteers, :specific_volunteers], Event
      can :sign_ups, EventCategory
      can :sign_ups, Event
      can [:manage_all, :show_all], :registrant
      can [:add_events, :create_artistic], Registrant
      can [:read, :create, :list], Email
    end
  end

  def define_competition_admin_roles(user)
    if user.has_role? :competition_admin
      can :manage, :director
      can :manage, :ineligible_registrant
      can [:crud], AgeGroupType
      can :update_row_order, AgeGroupEntry
      can [:crud, :set_places, :lock, :unlock], Competition
      can [:crud], CombinedCompetition
      can [:crud], CombinedCompetitionEntry
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

    define_payment_admin_roles(user)
    define_event_planner_roles(user)
    define_competition_admin_roles(user)
    define_membership_admin_roles(user)
    define_volunteer_roles(user)

    # #################################################
    # End new role definitions
    # #################################################

    if user.has_role? :awards_admin
      can [:read, :results, :publish, :unpublish, :award], Competition
      can :manage, AwardLabel
    end

    # Competitor Assignment
    if user.has_role? :admin
      set_data_entry_volunteer_abilities(user)
      can [:results, :summary], Event
      can :sign_ups, EventCategory
      can [:read, :lock], Competition
      can :manage, Competitor
      can :manage, Member
      can :manage, ImportResult
      can :manage, AwardLabel
      can :manage, TimeResult
      can :manage, ExternalResult
      can :manage, RegistrantGroup
      can :manage, Judge
      if config.usa_membership_config?
        can :manage, :usa_membership
      end
      can :read, VolunteerOpportunity
    end

    # Scoring abilities
    if user.has_role? :data_entry_volunteer
      set_data_entry_volunteer_abilities(user)
    end

    if user.has_role? :director, :any
      set_director_abilities(user)
    end

    define_registrant_ability(user)

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

  # Registrant
  def define_registrant_ability(user)
    if user.has_role? :admin
      # can :create, RegFee
      can :manage_all, :registrant
      can :bag_labels, :registrant

      can [:read, :create, :list], Email
      can :create_artistic, Registrant
      can [:index, :create, :destroy], RegistrantExpenseItem
      can :manage, :event_song
    end

    unless artistic_reg_closed?
      can [:create_artistic], Registrant
    end

    unless event_sign_up_closed?
      can [:add_events], Registrant
    end

    unless reg_closed?
      # can [:create], RegistrantExpenseItem, :user_id => user.id
      can [:index, :create, :destroy], RegistrantExpenseItem do |rei|
        (!rei.system_managed?) && (user.editable_registrants.include?(rei.registrant))
      end
    end

    # :read_contact_info allows viewing the contact_info block (additional_registrant_accesess don't allow this)
    can [:waiver, :read_contact_info], Registrant, user_id: user.id
    can [:read_contact_info], Registrant do |reg|
      user.editable_registrants.include?(reg)
    end
  end
end
