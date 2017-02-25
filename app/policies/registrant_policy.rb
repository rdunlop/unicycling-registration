class RegistrantPolicy < ApplicationPolicy
  # create a new registrant
  def create?
    (user_record? && !new_registration_closed?) || super_admin?
  end

  def create_from_previous?
    create?
  end

  def duplicate_registrant?
    event_planner? || payment_admin? || convention_admin? || super_admin?
  end

  # show the summary page
  def show?
    user_record? || user.accessible_registrants.include?(record) || event_planner? || super_admin?
  end

  # Action to cause a re-query of the USA Membership database
  def refresh_usa_status?
    show?
  end

  # ###########################
  # WIZARD STEPS
  # ###########################
  def add_name?
    update?
  end

  def add_events?
    return false unless record.competitor?
    return true if event_planner? || super_admin?
    (user_record? || shared_editable_record?) && (!config.event_sign_up_closed? || !registration_closed?)
    # change this to allow add_events when registration is closed, but events date is open
    # !config.event_sign_up_closed?
    # BUT, still allow viewing of the events page after events have closed, but registration is open?
  end

  def set_wheel_sizes?
    return false unless config.registrants_should_specify_default_wheel_size?
    record.competitor? && update? && record.try(:age).to_i <= config.wheel_size_configuration_max_age
  end

  def add_volunteers?
    (config.volunteer_option != "none") && update?
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
    user_record? || user.editable_registrants.include?(record) || add_contact_details? || super_admin?
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

  def really_destroy?
    super_admin?
  end

  # view the registrant-specific payments
  def payments?
    user_record? || payment_admin? || super_admin?
  end

  def results?
    record.competitor?
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
