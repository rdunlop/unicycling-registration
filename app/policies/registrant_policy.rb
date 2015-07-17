class RegistrantPolicy < ApplicationPolicy
  # create a new registrant
  def create?
    (user_record? && !registration_closed?) || super_admin?
  end

  # show the summary page
  def show?
    user_record? || user.accessible_registrants.include?(record) || event_planner? || super_admin?
  end

  # ###########################
  # WIZARD STEPS
  # ###########################
  def add_name?
    update?
  end

  def add_events?
    return false unless record.competitor
    return true if event_planner? || super_admin?
    (user_record? || shared_editable_record?) && (!config.event_sign_up_closed?)
    # change this to allow add_events when registration is closed, but events date is open
    # !config.event_sign_up_closed?
    # BUT, still allow viewing of the events page after events have closed, but registration is open?
  end

  def set_wheel_sizes?
    record.competitor && update? && record.try(:age).to_i <= 10
  end

  def add_volunteers?
    update?
  end

  def add_contact_details?
    update?
  end

  def expenses?
    update?
  end

  def wicked_finish?
    true
  end

  # is there any action to which I am able to update?
  def update_any_data?
    add_name? || add_events? || set_wheel_sizes? || add_volunteers? || add_contact_details? || expenses?
  end

  # can I update any of my registration data?
  def update?
    return true if event_planner? || super_admin?
    (user_record? || shared_editable_record?) && !registration_closed?
  end

  # ###########################
  # END WIZARD STEPS
  # ###########################

  # view the mailing address of a registrant
  def show_contact_details?
    user_record? || user.editable_registrants.include?(record) || super_admin?
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

  # per-registrant results
  def results?
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
