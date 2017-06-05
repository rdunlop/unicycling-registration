class RegistrantGroupLeaderPolicy < ApplicationPolicy
  def create?
    # must be member being removed, OR
    # convention_admin event-director (if event) or super_admin
    super_admin?
  end

  def destroy?
    # must be SELF,
    # or convention_admin event-director (if event) or super_admin
    super_admin?
  end
end
