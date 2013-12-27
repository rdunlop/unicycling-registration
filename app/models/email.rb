class Email
  include Virtus
  include ActiveModel::Validations
  include ActiveModel::Conversion

  attribute :confirmed_accounts, Boolean
  attribute :paid_reg_accounts, Boolean
  attribute :unpaid_reg_accounts, Boolean
  attr_accessor :subject, :body
  validates_presence_of :subject, :body

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

  def self.addresses_for_confirmed_accounts
    return User.confirmed.map{|user| user.email }
  end

  def self.addresses_for_paid_reg_accounts
    self.addresses_for_confirmed_accounts - self.addresses_for_unpaid_reg_accounts
  end

  def self.addresses_for_unpaid_reg_accounts
    return User.unpaid_reg_fees.map{|user| user.email }
  end

  def email_addresses
    if self.confirmed_accounts
      Email.addresses_for_confirmed_accounts
    elsif self.paid_reg_accounts
      Email.addresses_for_paid_reg_accounts
    elsif self.unpaid_reg_accounts
      Email.addresses_for_unpaid_reg_accounts
    else
      []
    end
  end

  def persisted?
    false
  end
end
