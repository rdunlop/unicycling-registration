class PaymentPolicy < ApplicationPolicy

  def index?
    true
  end

  def show?
    user_record? || payment_admin? || super_admin?
  end

  def create?
    user_record? || super_admin?
  end

  def new?
    !registration_closed? || super_admin?
  end

  [:create, :complete, :apply_coupon].each do |meth|
    define_method("#{meth}?") do
      manage?
    end
  end

  def offline_payment?
    true
  end

  def summary?
    payment_admin? || super_admin?
  end

  def fake_complete?
    config.test_mode
  end

  private

  def manage?
    (user_record? && !registration_closed?) || super_admin?
  end

  def user_record?
    record.user == user
  end

  class Scope < Scope
    def resolve
      if payment_admin? || super_admin?
        scope.all
      else
        scope.where(user_id: user.id)
      end
    end
  end

end
