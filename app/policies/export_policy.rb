class ExportPolicy < ApplicationPolicy
  def index?
    download_payment_details? || download_events? || results?
  end

  def download_competitors_for_timers?
    user.has_role?(:race_official, :any) || super_admin?
  end

  def download_events?
    super_admin?
  end

  def download_payment_details?
    user.has_role?(:export_payment_lists) || super_admin?
  end

  def results?
    super_admin?
  end
end
