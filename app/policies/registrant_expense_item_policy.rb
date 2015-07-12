class RegistrantExpensePolicy < ApplicationPolicy

  def create?
    manage? || super_admin?
  end

  def destroy?
    manage? || super_admin?
  end

  private

  def manage?
    (!record.system_managed?) && (user.editable_registrants.include?(record.registrant))
  end
end
