class RegistrantPolicy < ApplicationPolicy
  def create?
    (user_record? && !registration_closed?) || super_admin?
  end

  def show?
    user_record? || user.accessible_registrants.include?(record) || event_planner? || super_admin?
  end

  def show_contact_details?
    user_record? || user.editable_registrants.include?(record) || super_admin?
  end

  def update?
    event_planner? || ((user_record? || shared_editable_record?) && !registration_closed?) || super_admin?
  end

  def destroy?
    (user_record? && !registration_closed?) || event_planner? || super_admin?
  end

  def waiver?
    show?
  end

  def undelete?
    super_admin?
  end

  # view the registrant-specific payments
  def payments?
    super_admin?
  end

  private

  def user_record?
    record.user == user
  end

  def shared_editable_record?
    user.editable_registrants.include?(record)
  end

  # class Scope < Scope
  #   def resolve
  #     if payment_admin?
  #       scope.all
  #     end

  #     if registration_closed?
  #       scope.none
  #     else
  #       scope.where(user_id: user.id)
  #     end
  #   end
  # end
end
