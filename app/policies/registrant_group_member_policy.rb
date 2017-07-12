class RegistrantGroupMemberPolicy < ApplicationPolicy
  def create?
    # must be leader, or convention_admin event-director (if event) or super_admin
    group_leader?(record.registrant_group) || convention_admin? || director?(record.registrant_group.registrant_group_type.source_element) || super_admin?
  end

  def destroy?
    # allow member to remove self
    return true if user.registrants.include?(record.registrant)
    create?
  end

  def promote?
    create?
  end

  def request_leader?
    # must be signed in
    true
  end

  private

  def group_leader?(group)
    group.registrant_group_leaders.any?{|grl| grl.user == user }
  end
end
