class SystemLabelTypePolicy < ApplicationPolicy
  def index?
    super_admin?
  end

  def new?
    super_admin?
  end

  def create?
    super_admin?
  end

  def edit?
    super_admin?
  end

  def update?
    super_admin?
  end

  def destroy?
    super_admin?
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
