class RegistrantGroupPolicy < ApplicationPolicy
  def index?
    signed_in?
  end

  def create?
    signed_in?
  end

  def update?
    super_admin? || group_leader?(record) || convention_admin? || director?(record.registrant_group_type.source_element)
  end

  def destroy?
    update?
  end

  private

  def signed_in?
    true
  end

  def group_leader?(group)
    group.registrant_group_leaders.any?{|grl| grl.user == user }
  end
end
