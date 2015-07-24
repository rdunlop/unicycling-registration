class AdminPermissionPolicy < ApplicationPolicy
  def index?
    convention_admin? || competition_admin? || super_admin?
  end

  def set_role?
    convention_admin? || competition_admin? || super_admin?
  end

  def set_password?
    convention_admin? || competition_admin? || super_admin?
  end

  # display the current access control code
  def display_acl?
    convention_admin? || super_admin?
  end
end
