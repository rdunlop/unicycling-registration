class RegistrantGroupLeaderPolicy < ApplicationPolicy
  def create?
    # allow leaders to add leaders
    return true if group_leader?(record.registrant_group)

    convention_admin? || director?(record.registrant_group.registrant_group_type.source_element) || super_admin?
  end

  def destroy?
    # allow leader to remove self
    return true if group_leader?(record.registrant_group)

    convention_admin? || director?(record.registrant_group.registrant_group_type.source_element) || super_admin?
  end

  private

  def group_leader?(group)
    group.registrant_group_leaders.any?{|grl| grl.user == user }
  end
end
