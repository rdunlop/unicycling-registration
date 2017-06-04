class RegistrantGroupPolicy < ApplicationPolicy
  def index?
    super_admin?
  end

  def new?
    super_admin?
  end

  def join?
    super_admin?
  end

  def update?
    super_admin?
  end

  def destroy?
    super_admin?
  end

  def add_member?
    super_admin?
  end

  def remove_member?
    super_admin?
  end

  def promote?
    super_admin?
  end

  def leave?
    super_admin?
  end

  def request_leader?
    super_admin?
  end
end
