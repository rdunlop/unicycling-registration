class SampleDataPolicy < ApplicationPolicy
  def create?
    super_admin? && config.test_mode?
  end
end
