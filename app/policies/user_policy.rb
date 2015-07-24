class UserPolicy < ApplicationPolicy
  def registrants?
    record == user || payment_admin? || event_planner? || super_admin?
  end

  # view the user-specific payments
  def payments?
    record == user || super_admin?
  end

  def create_payments?
    !registration_closed? || super_admin?
  end

  # view all registrant-information
  def registrant_information?
    event_planner? || super_admin?
  end

  def add_events?
    !event_sign_up_closed? || event_planner? || super_admin?
  end

  def add_artistic_events?
    !artistic_reg_closed? || event_planner? || super_admin?
  end

  def manage_music?
    music_dj? || super_admin?
  end

  def manage_awards?
    awards_admin? || super_admin?
  end

  def manage_usa_memberships?
    config.usa_membership_config? && (membership_admin? || super_admin?)
  end

  # is this user allowed to make manual-received payments/etc?
  def manage_all_payments?
    payment_admin? || super_admin?
  end

  # can we download payment details
  def download_payments?
    super_admin?
  end

  # send e-mails, etc
  def contact_registrants?
    event_planner? || super_admin?
  end

  # the old way of doing manual payments
  def manage_old_payment_adjustments?
    super_admin?
  end

  def view_modification_history?
    super_admin?
  end

  def logged_in?
    true
  end

  def under_development?
    super_admin?
  end

  def view_data_entry_menu?
    data_recording_volunteer? || director? || super_admin?
  end

  private

  def event_sign_up_closed?
    config.event_sign_up_closed?
  end

  def artistic_reg_closed?
    config.artistic_closed?
  end
end
