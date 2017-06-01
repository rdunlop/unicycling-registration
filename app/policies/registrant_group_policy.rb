class RegistrantGroupPolicy < ApplicationPolicy
  def index?
    true
  end

  def new?
    true
  end

  def join?
    true
  end

  def update?
    true
  end

  def add_member?
    true
  end

  def remove_member?
    true
  end

  def promote?
    true
  end

  def leave?
    true
  end

  def request_leader?
    true
  end
end
