class ImportPolicy < ApplicationPolicy
  def create?
    super_admin?
  end
end
