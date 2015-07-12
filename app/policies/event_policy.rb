class EventPolicy < ApplicationPolicy

  def sign_ups?
    director?(record) || competition_admin? || super_admin?
  end

  def summary?
    manage?
  end

  def general_volunteers?
    manage?
  end

  def specific_volunteers?
    manage?
  end

  private

  def manage?
    director? || super_admin?
  end
end
