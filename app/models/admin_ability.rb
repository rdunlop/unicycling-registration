class AdminAbility
  include CanCan::Ability

  def initialize(user)
    if user.nil?
    else
      if user.admin or user.super_admin
        can :manage, Event
        can :manage, Payment
        can :manage, Registrant
        can :manage, :history
      end

      if user.super_admin
        can :manage, :export
        can :manage, User
        can :manage, StandardSkillEntry
        can :manage, StandardSkillRoutine
      end
    end
  end
end
