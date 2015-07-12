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

    can :read, AgeGroupType
    can :show, PublishedAgeGroupEntry do |entry|
      entry.published_at.present?
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
      can :manage, RegistrantGroup
      can :manage, Judge
      can :read, VolunteerOpportunity
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
