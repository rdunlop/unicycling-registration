class AdminAbility
  include CanCan::Ability

  def initialize(user)
    if user.nil?
    else
      if user.has_role? :admin or user.has_role? :super_admin
        can :manage, Event
        can :manage, Payment
        can :manage, Registrant
        can :email, Registrant
      end

      if user.has_role? :super_admin
        can :manage, :export
        can :manage, User
        can :manage, StandardSkillEntry
        can :manage, StandardSkillRoutine
        can :manage, AgeGroupType
        can :manage, AgeGroupEntry
      end
    end
  end
end
