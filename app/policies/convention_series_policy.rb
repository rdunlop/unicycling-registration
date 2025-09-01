class ConventionSeriesPolicy < ApplicationPolicy
  def index?
    convention_admin? || super_admin?
  end

  def create?
    admin_on_all_members?
  end

  def show?
    admin_on_all_members?
  end

  def destroy?
    admin_on_all_members?
  end

  def add?
    admin_on_all_members?
  end

  def remove?
    admin_on_all_members?
  end

  private

  def admin_on_all_members?
    record.subdomains.all? do |subdomain|
      Apartment::Tenant.switch(subdomain) do
        tenant_user = User.find(user.id)
        tenant_user.has_role?(:convention_admin) || tenant_user.has_role?(:super_admin)
      end
    end
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if super_admin?
        scope
      else
        scope.none
      end
    end
  end
end
