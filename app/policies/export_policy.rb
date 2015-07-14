class ExportPolicy < ApplicationPolicy

  def index?
    super_admin?
  end

  def download_competitors_for_timers?
    user.has_role?(:race_official, :any) || super_admin?
  end

  def download_events?
    super_admin?
  end

  def download_payment_details?
    super_admin?
  end

  def results?
    super_admin?
  end
end
