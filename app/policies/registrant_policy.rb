class RegistrantPolicy < ApplicationPolicy
  # create a new registrant
  def create?
    return true if super_admin?

    user_record? && !new_registration_closed?(record.registrant_type) && registration_type_for_sale?(record.registrant_type)
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

  # Action to cause a re-query of the Membership database
  def refresh_organization_status?
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

    my_record? && (!config.event_sign_up_closed? || !registration_closed?(record.registrant_type))
    # change this to allow add_events when registration is closed, but events date is open
    # !config.event_sign_up_closed?
    # BUT, still allow viewing of the events page after events have closed, but registration is open?
  end

  def set_wheel_sizes?
    return false unless config.registrants_should_specify_default_wheel_size?

    record.competitor? && update? && record.try(:age).to_i <= config.wheel_size_configuration_max_age
  end

  def add_volunteers?
    config.volunteer? && update?
  end

  def add_contact_details?
    # Temporary hack to allow uploading medical certificates after
    # registration is closed
    return true if config.require_medical_certificate? && Date.current < Date.new(2022, 7, 26)

    update?
  end

  def lodging?
    return false unless config.has_lodging?
    return true if event_planner? || super_admin?

    my_record? && !config.lodging_sales_closed?
  end

  def expenses?
    return false unless config.has_expenses?
    return true if event_planner? || super_admin?

    my_record? && !config.add_expenses_closed?
  end

  def set_organization_membership?
    return false unless config.organization_membership_config?

    update?
  end

  def wicked_finish?
    true
  end

  # is there any action to which I am able to update?
  def update_any_data?
    add_name? || add_events? || set_wheel_sizes? || add_volunteers? || add_contact_details? || lodging? || expenses? || set_organization_membership?
  end

  # can I update any of my registration data?
  def update?
    return true if event_planner? || super_admin?

    my_record? && !registration_closed?(record.registrant_type)
  end

  def my_record?
    (user_record? || shared_editable_record?)
  end

  # ###########################
  # END WIZARD STEPS
  # ###########################

  # view the mailing address of a registrant
  def show_contact_details?
    my_record? || add_contact_details? || super_admin?
  end

  def destroy?
    (user_record? && !registration_closed?(record.registrant_type)) || event_planner? || super_admin?
  end

  def waiver?
    show?
  end

  def undelete?
    event_planner? || super_admin?
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

  def contact_registrants?
    director? || event_planner? || super_admin?
  end

  private

  def registration_type_for_sale?(registrant_type)
    return true if RegistrationCost.for_type(registrant_type).none?

    RegistrationCost.for_type(registrant_type).current_period.present?
  end

  def user_record?
    record.user == user
  end

  def shared_editable_record?
    user.editable_registrants.include?(record)
  end
end
