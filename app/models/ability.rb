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
    can [:index, :scores], :result
    can [:announcer, :start_list], Competition
    can [:acl, :set_acl, :code, :use_code], :permission
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
    can :data_entry_menu, :welcome

    can [:read], Competitor
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
    can :manage, TieBreakAdjustment
  end

  def director_and_unlocked(user, competition)
    !competition.locked && user.has_role?(:director, competition.try(:event))
  end

  def set_director_abilities(user)
    set_data_entry_volunteer_abilities(user)

    # Abilities to be able to read data about a competition
    can :read, Competition do |competition|
      user.has_role? :director, competition.event
    end

    can [:read], Score do |score|
      user.has_role? :director, score.competition.event
    end

    can [:export_scores, :results, :result], Competition do |comp|
      user.has_role? :director, comp.event
    end

    can [:read], Judge do |judge|
      user.has_role? :director, judge.competition.try(:event)
    end

    can :manage, DataEntryVolunteer
    can :create_race_official, :permission

    # :results is for printing
    can [:results, :sign_ups], Event do |ev|
      user.has_role? :director, ev
    end
    can :summary, Event
    can :sign_ups, EventCategory
    #     #this is the way recommended by rolify...but it must not be called with the class (ie: do not call "can? :results, Event")
    #     can [:read, :results, :sign_ups], Event, id: Event.with_role(:director, user).pluck(:id)

    # Abilities to be able to change data about a competition
    can :manage, Competitor do |comp|
      director_and_unlocked(user, comp.competition)
    end

    can :manage, Member do |member|
      director_and_unlocked(user, member.competitor.competition)
    end

    # TODO: is there a way to scope this better? and also to honor the 'locked' status
    can [:update_row_order], Competitor, if: user.has_role?(:director, :any)

    can [:set_sort, :toggle_final_sort, :sort_random, :lock], Competition do |comp|
      director_and_unlocked(user, comp)
    end

    # Data Management
    can :manage, ImportResult do |import_result|
      director_and_unlocked(user, import_result.competition)
    end

    can :manage, TimeResult do |time_result|
      director_and_unlocked(user, time_result.competition)
    end

    can [:crud, :copy_judges], Judge do |judge|
      # Only allow creating judges when there are no scores yet entered
      (judge.scores.count == 0) && (director_and_unlocked(user, judge.competition))
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

    # #################################################
    # Begin new role definitions
    # #################################################
    if user.has_role? :convention_admin
      can :manage, TenantAlias
      can :manage, EventConfiguration
      cannot :cache, EventConfiguration
      can :manage, :convention_setup
      can :crud, ExpenseGroup
      can :crud, ExpenseItem
      can :crud, CouponCode
      can :crud, RegistrationPeriod
      can :crud, Category
      can :crud, Event
      can :crud, EventChoice
      can :crud, EventCategory
      can :crud, VolunteerOpportunity
      can :read, :onsite_registration
      can :display_acl, :permission
      can :toggle_visibility, ExpenseGroup
      can [:read, :set_role, :set_password], :permission
      can :manage, :translation
    end

    if user.has_role? :music_dj
      can :list, :song
      # automatically can download music via S3 links
    end

    if user.has_role? :translator
      can :manage, :translation
      can :manage, :all_site_translations
    end

    if user.has_role? :payment_admin
      can :summary, Payment
      can [:new, :choose, :create], :manual_payment
      can :set_reg_fee, :registrant
      can [:read], Registrant
      can [:list, :payments, :payment_details], :export_payment
      can [:download_all], :export_registrant
      # Allow adding items which only admins can add
      can :admin_view, ExpenseItem
      can :details, ExpenseItem
      can :read, CouponCode
    end

    if user.has_role? :event_planner
      can [:summary, :general_volunteers, :specific_volunteers], Event
      can :sign_ups, EventCategory
      can [:manage_all, :show_all], :registrant
      can [:read], Registrant
      can [:read, :create, :list], Email
    end

    if user.has_role? :competition_admin
      can :read, :competition_setup
      can :manage, :director
      can :manage, :ineligible_registrant
      can [:crud], Competition
      #can [:read, :set_role, :set_password], :permission
    end

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
      can [:set_password], :permission
      if config.usa_membership_config
        can :manage, :usa_membership
      end
      can :read, VolunteerOpportunity

      can :manage, :payment_adjustment
    end

    if user.has_role?(:race_official) || user.has_role?(:admin)
      # includes :view_heat, and :dq_competitor
      can :manage, LaneAssignment
      can :download_competitors_for_timers, :export
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

    # can :create, Song do
    #  user.has_role? :admin
    # end
    unless config.music_submission_ended?
      can [:crud, :file_complete, :add_file, :my_songs, :create_guest_song], Song, :user_id => user.id
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
    can :read, Payment if user.has_role? :admin
    can :manage, Payment if user.has_role? :super_admin
    can :read, Payment, :user_id => user.id
    unless reg_closed?
      can [:new, :create, :complete, :apply_coupon], Payment
    end
    can [:offline], Payment
    if user.has_role?(:admin)
      can [:new, :exchange_choose, :exchange_create, :adjust_payment_choose, :onsite_pay_confirm, :onsite_pay_choose, :onsite_pay_create], :payment_adjustment
    end
  end

  # Registrant
  def define_registrant_ability(user)
    if user.has_role? :admin
      # can :create, RegFee
      can :set_reg_fee, :registrant
      can :undelete, :registrant
      can :manage_all, :registrant
      can :bag_labels, :registrant

      can [:read, :create, :list], Email
      can :crud, Registrant
      can :crud, CompetitionWheelSize
      can :create_artistic, Registrant
      can [:index, :create, :destroy], RegistrantExpenseItem
      can [:crud, :file_complete, :add_file], Song
      can :list, :song
      can [:crud], CompetitionWheelSize
    end
    # not-object-specific
    can :empty_waiver, Registrant
    can :all, Registrant
    can :subregion_options, Registrant

    unless artistic_reg_closed?
      can [:create_artistic], Registrant
    end

    unless event_sign_up_closed?
      can [:add_events], Registrant
    end

    unless reg_closed?
      can [:update, :destroy], Registrant, :user_id => user.id
      can [:update], Registrant do |reg|
        user.editable_registrants.include?(reg)
      end
      can :crud, CompetitionWheelSize # allowed, because we have authorize! calls in the controller

      # can [:create], RegistrantExpenseItem, :user_id => user.id
      can [:index, :create, :destroy], RegistrantExpenseItem do |rei|
        (!rei.system_managed) && (user.editable_registrants.include?(rei.registrant))
      end
      can :create, Registrant # necessary because we set the user in the controller?
    end

    can :read, Registrant do |reg|
      user.accessible_registrants.include?(reg)
    end

    # :read_contact_info allows viewing the contact_info block (additional_registrant_accesess don't allow this)
    can [:waiver, :read_contact_info], Registrant, :user_id => user.id
    can [:read_contact_info], Registrant do |reg|
      user.editable_registrants.include?(reg)
    end
  end
end
