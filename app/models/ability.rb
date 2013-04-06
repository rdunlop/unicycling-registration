class Ability
  include CanCan::Ability

  def initialize(user)
    if user.nil?
    else
      if user.has_role? :super_admin
        can :access, :rails_admin
        can :dashboard
        can :manage, :all

        can :manage, Category
        can :manage, Event
        can :manage, EventChoice
        can :manage, EventConfiguration
        can :manage, ExpenseGroup
        can :manage, ExpenseItem
        can :manage, Registrant
        can :manage, RegistrationPeriod
        can :manage, StandardSkillRoutineEntry
        can :manage, StandardSkillRoutine
        can :all, StandardSkillRoutine
        can :manage, Payment
        can :manage, User
      elsif user.has_role? :admin
        can :manage, Registrant
        can :manage, Payment
        can :manage, StandardSkillRoutineEntry
        can :manage, StandardSkillRoutine
      else
        can :read, User, :id => user.id
        can [:read, :new, :create], AdditionalRegistrantAccess, :user_id => user.id
        can [:invitations, :decline, :accept_readonly], AdditionalRegistrantAccess do |aca|
          aca.registrant.user == user
        end
        can [:read, :all, :waiver], Registrant, :user_id => user.id
        can :read, Payment, :user_id => user.id

        unless EventConfiguration.closed?
          can [:update, :items, :update_items, :destroy], Registrant, :user_id => user.id
          can :create, Registrant # necessary because we set the user in the controller?
          can :new_noncompetitor, Registrant # necessary because we set the user in the controller?
          can [:new, :create], Payment
          can :manage, StandardSkillRoutine do |routine|
            user.registrants.include?(routine.registrant)
          end
          can :create, StandardSkillRoutine # necessary because we set the registrant in the controller?
          can :manage, StandardSkillRoutineEntry do |entry|
            can? :destroy, entry.standard_skill_routine
          end
        end
      end
    end
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
    cannot :club_admin, EventConfiguration
    cannot :normal, EventConfiguration
    cannot :fake_complete, Payment
    if @config.test_mode
      can :admin, EventConfiguration
      can :super_admin, EventConfiguration
      can :club_admin, EventConfiguration
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
