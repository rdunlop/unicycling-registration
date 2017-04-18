class RegFee
  include Virtus.model

  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  attribute :registrant_id, Integer
  attribute :registration_cost_id, Integer

  validates :registrant_id, :registration_cost_id, presence: true
  validate :registrant_is_not_paid
  validate :registrant_type_matches_registration_cost

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
    RegistrationCost.for_type(registrant.registrant_type).find_by(id: registration_cost_id).try(:expense_item_for, registrant)
  end

  private

  def registrant_is_not_paid
    return unless registrant.present?
    errors.add(:base, "This registrant is already paid") if registrant.reg_paid?
  end

  def registrant_type_matches_registration_cost
    return unless registrant.present?
    if new_registration_item.nil?
      errors.add(:base, "Registrant is #{registrant.registrant_type}, doesn't match RegistrationCost type")
    end
  end
end
