class Email
  include Virtus
  include ActiveModel::Validations
  include ActiveModel::Conversion

  attribute :confirmed_accounts, Boolean
  attribute :paid_reg_accounts, Boolean
  attribute :unpaid_reg_accounts, Boolean
  attribute :no_reg_accounts, Boolean
  attr_accessor :subject, :body
  validates_presence_of :subject, :body

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

  def self.addresses_for_confirmed_accounts
    User.confirmed.map{|user| user.email }
  end

  def self.addresses_for_paid_reg_accounts
    User.paid_reg_fees.map{|user| user.email }
  end

  def self.addresses_for_unpaid_reg_accounts
    User.unpaid_reg_fees.map{|user| user.email }
  end

  def self.addresses_for_no_reg_accounts
    (User.confirmed - User.all_with_registrants).map{|user| user.email }
  end

  def email_addresses
    res = []
    if self.confirmed_accounts
      res += Email.addresses_for_confirmed_accounts
    end
    if self.paid_reg_accounts
      res += Email.addresses_for_paid_reg_accounts
    end
    if self.unpaid_reg_accounts
      res += Email.addresses_for_unpaid_reg_accounts
    end
    if self.no_reg_accounts
      res += Email.addresses_for_no_reg_accounts
    end

    res
  end

  def persisted?
    false
  end
end
