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

  def initialize(user, allow_reg_modifications = false)
    @allow_reg_modifications = allow_reg_modifications

    if user.present?
      define_ability_for_logged_in_user(user)
    end
    # Even Non-Logged-In Users can still:

    can :read, StandardSkillEntry
    can :logo, EventConfiguration
    can :index, :result
    can :read, CombinedCompetition
    can :announcer, Competition
    can [:acl, :set_acl], :permission
    can :show, PublishedAgeGroupEntry do |entry|
      entry.published_at.present?
    end

    if config.test_mode
      # allow the user to upgrade their account in TEST MODE
      can :test_mode_role, EventConfiguration
      can :fake_complete, Payment
    else
      # disable for all
      cannot :test_mode_role, EventConfiguration
      cannot :fake_complete, Payment
    end

  end

  def set_data_entry_volunteer_abilities(user)

    can :read, Competitor
    can :read, Competition

    can :read, Judge, :user_id => user.id

    # Freestyle
    can :create, Score
    can [:read, :update, :destroy], Score do |score|
      score.try(:user) == user && !score.competitor.competition.locked
    end

    can [:create_scores], Competition do |competition|
      !competition.locked
    end

    # printing forms:
    can [:announcer, :heat_recording, :single_attempt_recording, :two_attempt_recording], Competition

    # data entry
    can :manage, ImportResult do |import_result|
      !import_result.competition.locked
    end
    cannot [:approve, :approve_heat], ImportResult

    can :manage, TwoAttemptEntry do |two_attempt_entry|
      !two_attempt_entry.competition.locked
    end

    # High/Long Data Entry
    can :manage, DistanceAttempt
  end

  def director_of_competition(user, competition)
    !competition.locked && user.has_role?(:director, competition.try(:event))
  end

  def set_director_abilities(user)
    set_data_entry_volunteer_abilities(user)

    # :read is main director menu-page
    # :results is for printing
    can [:results, :sign_ups], Event do |ev|
      user.has_role? :director, ev
    end
    can :summary, Event
    can :sign_ups, EventCategory
=begin
    #this is the way recommended by rolify...but it must not be called with the class (ie: do not call "can? :results, Event")
    can [:read, :results, :sign_ups], Event, id: Event.with_role(:director, user).pluck(:id)
=end

    can :manage, Competitor do |comp|
      director_of_competition(user, comp.competition)
    end

    can :read, Competition do |competition|
      user.has_role? :director, competition.event
    end

    can :manage, Member do |member|
      director_of_competition(user, member.competitor.competition)
    end

    can [:read], Score do |score|
      user.has_role? :director, score.competition.event
    end

    can [:export_scores, :results, :result], Competition do |comp|
      user.has_role? :director, comp.event
    end

    can [:sort, :sort_random, :lock], Competition do |comp|
      director_of_competition(user, comp)
    end

    can :manage, ImportResult do |import_result|
      director_of_competition(user, import_result.competition)
    end

    can :manage, TimeResult do |time_result|
      director_of_competition(user, time_result.competition)
    end

    can :manage, DataEntryVolunteer

    can :create_race_official, :permission

    can [:crud, :copy_judges], Judge do |judge|
      (judge.scores.count == 0) && (director_of_competition(user, judge.competition))
    end
    can [:read], Judge do |judge|
      (director_of_competition(user, judge.competition))
    end
  end

  def define_ability_for_logged_in_user(user)
    alias_action :create, :read, :update, :destroy, :to => :crud

    if user.roles.any?
      can :data_entry_menu, :welcome
    end

    if user.has_role? :super_admin
      can :judging_menu, :welcome
      can :access, :rails_admin
      can :dashboard
      can :manage, :all
      return # required in order to allow rails_admin to function
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
      can [:directors], :permission
      if config.usa
        can :manage, :usa_membership
      end
      can :read, :volunteer

      can :manage, :payment_adjustment
      can :display_acl, :permission
    end

    if user.has_role? :event_planner
      can :summary, Event
      can :sign_ups, EventCategory
      can :manage_all, Registrant
      can :read, Registrant
      can [:email, :send_email], Registrant
      can [:directors], :permission
    end

    if user.has_role? :music_dj
      can :list, Song
    end

    if user.has_role? :race_official or user.has_role? :admin
      # includes :view_heat, and :dq_competitor
      can :manage, LaneAssignment
    end

    # Scoring abilities
    if user.has_role? :data_entry_volunteer
      set_data_entry_volunteer_abilities(user)
    end

    if user.has_role? :director, :any
      set_director_abilities(user)
    end

    define_payment_ability(user)

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

    #can :create, Song do
    #  user.has_role? :admin
    #end
    unless config.music_submission_ended?
      can [:crud, :file_complete, :add_file], Song do |song|
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
    unless reg_closed?
      can [:new, :create], Payment
    end
    can [:new, :adjust_payment_choose, :onsite_pay_confirm, :onsite_pay_choose, :onsite_pay_create], :payment_adjustment
    can [:read], Registrant
  end

  # Registrant
  def define_registrant_ability(user)
    if user.has_role? :admin
      can :reg_fee, Registrant
      can :update_reg_fee, Registrant
      can :manage_all, Registrant
      can [:email, :send_email], Registrant
      can :bag_labels, Registrant
      can :undelete, Registrant
      can :crud, Registrant
      can :create_artistic, Registrant
      can [:index, :create, :destroy], RegistrantExpenseItem
      can [:crud, :file_complete, :add_file, :list], Song
    end
    # not-object-specific
    can :empty_waiver, Registrant
    can :all, Registrant

    unless artistic_reg_closed?
      can [:create_artistic], Registrant
    end

    unless reg_closed?
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
