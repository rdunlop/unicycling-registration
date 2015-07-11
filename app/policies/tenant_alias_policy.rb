class TenantAliasPolicy < ApplicationPolicy

  def manage?
    convention_admin? || super_admin?
  end

end
