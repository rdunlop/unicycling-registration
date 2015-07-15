class CouponCodeSummaryPolicy < ApplicationPolicy
  def show?
    convention_admin? || payment_admin? || super_admin?
  end
end
