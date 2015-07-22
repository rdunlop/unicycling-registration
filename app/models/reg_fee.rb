class RegFee
  include Virtus.model

  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  attribute :registrant_id, Integer
  attribute :registration_period_id, Integer

  validates :registrant_id, :registration_period_id, presence: true
  validate :registrant_is_not_paid

  def registrant_is_not_paid
    return unless registrant.present?
    errors[:base] << "This registrant is already paid" if registrant.reg_paid?
  end

  def persisted?
    false
  end

  def save
    return false if invalid?

    registrant.set_registration_item_expense(new_registration_item)
  end

  def registrant
    return nil unless registrant_id.present?
    @registrant ||= Registrant.find(registrant_id)
  end

  def new_registration_item
    registration_period.expense_item_for(registrant.competitor?)
  end

  private

  def registration_period
    RegistrationPeriod.find(registration_period_id)
  end
end
