class RefundPolicy < ApplicationPolicy
  def show?
    payment_admin? || super_admin?
  end
end
