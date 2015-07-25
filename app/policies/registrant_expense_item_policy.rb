class RegistrantExpenseItemPolicy < ApplicationPolicy
  def create?
    manage?
  end

  def destroy?
    manage?
  end

  private

  # need to create specs for this
  def manage?
    can_manage_item? && (user_match? || payment_admin? || super_admin?)
  end

  def can_manage_item?
    !record.system_managed?
  end

  def user_match?
    user.editable_registrants.include?(record.registrant)
  end
end
