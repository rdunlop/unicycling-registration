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

  def manage_music?
    music_dj? || super_admin?
  end

  # is this user allowed to make manual-received payments/etc?
  def manage_all_payments?
    payment_admin? || super_admin?
  end

  # can we download payment details
  def download_payments?
    super_admin?
  end

  # the old way of doing manual payments
  def manage_old_payment_adjustments?
    super_admin?
  end

  def logged_in?
    true
  end

end
