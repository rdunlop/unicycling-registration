class ManualPaymentDetail
  include Virtus.model

  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  attribute :registrant_expense_item_id, Integer
  attribute :pay_for, Boolean
  validates :registrant_expense_item_id, presence: true

  # these are derived from the REI
  delegate :registrant_id, :line_item, :free, :total_cost, :details, to: :registrant_expense_item

  def initialize(params = {})
    params.each do |name, value|
      send("#{name}=", value)
    end
  end

  def registrant_expense_item
    RegistrantExpenseItem.find(registrant_expense_item_id)
  end

  def registrant
    Registrant.find(registrant_id)
  end

  def persisted?
    false
  end
end
