class Ability
  include CanCan::Ability

  def is_admin(user)
    user.admin || user.super_admin
  end

  def initialize(user)
    if user.nil?
    else
      if is_admin(user)
        can :manage, Category
        can :manage, Event
        can :manage, EventChoice
        can :manage, EventConfiguration
        can :manage, Registrant
        can :manage, RegistrationPeriod
        can :manage, Payment
      else
        can [:read, :update], Registrant do |reg|
          reg.user == user
        end
        can :create, Registrant #XXX necessary because we set the user in the controller?
        can :new_noncompetitor, Registrant #XXX necessary because we set the user in the controller?

        can [:new, :create], Payment
        can :show, Payment do |payment|
          payment.user == user
        end
      end
    end
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
