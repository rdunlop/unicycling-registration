class Email
  include Virtus.model
  include ActiveModel::AttributeMethods
  include ActiveModel::Validations
  include ActiveModel::Conversion

  attribute :confirmed_accounts, Boolean
  attribute :paid_reg_accounts, Boolean
  attribute :unpaid_reg_accounts, Boolean
  attribute :no_reg_accounts, Boolean
  attribute :competition_id, Array
  attribute :category_id, Integer

  attr_accessor :subject, :body
  validates_presence_of :subject, :body

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

  def competitions
    return @competitions if @competitions
    @competitions = []
    competition_id.each do |cid|
      @competitions << Competition.find(cid) if cid.present?
    end
    @competitions
  end

  def category
    Category.find(category_id) if category_id.present?
  end

  def filter_description
    if confirmed_accounts
      "Confirmed User Accounts"
    elsif paid_reg_accounts
      "User Accounts with ANY Registrants who have Paid Reg Fees"
    elsif unpaid_reg_accounts
      "User Accounts with ANY Registrants who have NOT Paid Reg Fees"
    elsif no_reg_accounts
      "User Accounts with No Registrants"
    elsif competition_id.any?
      "Emails of users/registrants associated with #{competitions.map(&:to_s).join(' ')}"
    elsif category_id.present?
      "Emails of users/registrants associated with any competition in #{category}"
    else
      "Unknown"
    end
  end

  def filtered_user_emails
    if confirmed_accounts
      User.confirmed.map{|user| user.email }
    elsif paid_reg_accounts
      User.paid_reg_fees.map{|user| user.email }
    elsif unpaid_reg_accounts
      User.unpaid_reg_fees.map{|user| user.email }
    elsif no_reg_accounts
      (User.confirmed - User.all_with_registrants).map{|user| user.email }
    elsif competition_id.any?
      competitions.map(&:registrants).flatten.map(&:user).map(&:email).compact.uniq
    elsif category_id.present?
      category.events.map(&:competitor_registrants).flatten.map(&:user).map(&:email).compact.uniq
    else
      []
    end
  end

  def filtered_registrant_emails
    if competition_id.any?
      competitions.map(&:registrants).flatten.map(&:contact_detail).map(&:email).compact.uniq
    elsif category_id.present?
      category.events.map(&:competitor_registrants).flatten.map(&:contact_detail).map(&:email).compact.uniq
    else
      []
    end
  end

  def filtered_combined_emails
    (filtered_user_emails + filtered_registrant_emails).uniq.compact
  end

  def persisted?
    false
  end

  def serialize
    YAML.dump(self)
  end

  def self.deserialize(yaml)
    YAML.load(yaml)
  end
end
