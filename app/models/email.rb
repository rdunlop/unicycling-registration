class Email
  include Virtus
  include ActiveModel::Validations
  include ActiveModel::Conversion

  attribute :confirmed_accounts, Boolean
  attribute :unpaid_reg_accounts, Boolean
  attr_accessor :subject, :body
  validates_presence_of :subject, :body

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

  def email_addresses
    if self.confirmed_accounts
      return User.confirmed.map{|user| user.email }
    end
    if self.unpaid_reg_accounts
      return User.unpaid_reg_fees.map{|user| user.email }
    end
  end

  def persisted?
    false
  end
end
