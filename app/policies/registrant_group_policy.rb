class RegistrantGroupPolicy < ApplicationPolicy
  def index?
    # must be signed in
    super_admin?
  end

  def new?
    # must be signed in
    super_admin?
  end

  def update?
    # must be leader, or convention_admin event-director (if event) or super_admin
    super_admin?
  end

  def destroy?
    # NOT NEEDED?
    # must be leader, or convention_admin event-director (if event) or super_admin
    super_admin?
  end
end
