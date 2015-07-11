class EventConfigurationPolicy < ApplicationPolicy

  # Clear the redis caches
  def manage_cache?
    super_admin?
  end

  # Set up the base Convention settings
  def setup_convention?
    convention_admin? || super_admin?
  end

  # Set up the base Competition settings
  def setup_competition?
    competition_admin? || super_admin?
  end

  # Can we arbitrarily assign ourselves to new roles?
  def test_mode_role?
    record.test_mode?
  end
end
