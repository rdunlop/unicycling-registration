class RegistrantExpenseItemPolicy < ApplicationPolicy

  def create?
    manage? || super_admin?
  end

  def destroy?
    manage? || super_admin?
  end

  private

  # need to create specs for this
  def manage?
    (!record.system_managed?) && (user.editable_registrants.include?(record.registrant))
  end
end
