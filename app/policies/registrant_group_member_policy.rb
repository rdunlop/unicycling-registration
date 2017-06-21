class RegistrantGroupMemberPolicy < ApplicationPolicy
  def create?
    # must be leader, or convention_admin event-director (if event) or super_admin
    super_admin?
  end

  def destroy?
    # must be the member being removed, OR
    # must be leader, or convention_admin event-director (if event) or super_admin
    super_admin?
  end

  def promote?
    # must be leader, or convention_admin event-director (if event) or super_admin
    super_admin?
  end

  def request_leader?
    # must be signed in
    super_admin?
  end
end
