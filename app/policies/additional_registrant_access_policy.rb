class AdditionalRegistrantAccessPolicy < ApplicationPolicy

  def index?
    true
  end

  def create?
    user_match?
  end

  def decline?
    record.registrant.user == user
  end

  def accept_readonly?
    record.registrant.user == user
  end

  def invitation?
    true
  end

  private

  def user_match?
    record.user == user
  end

  def sign_ups?

    director? || event_planner? || super_admin?
  end

end
