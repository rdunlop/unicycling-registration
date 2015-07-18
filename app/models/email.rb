class Email
  include Virtus.model
  include ActiveModel::AttributeMethods
  include ActiveModel::Validations
  include ActiveModel::Conversion

  attribute :confirmed_accounts, Boolean
  attribute :paid_reg_accounts, Boolean
  attribute :unpaid_reg_accounts, Boolean
  attribute :no_reg_accounts, Boolean
  attribute :non_confirmed_usa, Boolean
  attribute :competition_id, Array
  attribute :category_id, Integer

  attr_accessor :subject, :body
  validates :subject, :body, presence: true

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
    elsif non_confirmed_usa
      "User Accounts with Registrants who are not USA-Members"
    elsif competitions.any?
      "Emails of users/registrants associated with #{competitions.map(&:to_s).join(' ')}"
    elsif category_id.present?
      "Emails of users/registrants associated with any competition in #{category}"
    else
      "Unknown"
    end
  end

  def filtered_user_emails
    filtered_users.map(&:email).compact.uniq if filtered_users.any?
  end

  def filtered_users
    if confirmed_accounts
      User.confirmed
    elsif paid_reg_accounts
      User.paid_reg_fees
    elsif unpaid_reg_accounts
      User.unpaid_reg_fees
    elsif no_reg_accounts
      (User.confirmed - User.all_with_registrants)
    elsif non_confirmed_usa
      Registrant.where(registrant_type: ["competitor", "noncompetitor"]).active_or_incomplete.all.reject(&:usa_membership_paid?).map(&:user).compact.uniq
    elsif competitions.any?
      competitions.map(&:registrants).flatten.map(&:user)
    elsif category_id.present?
      category.events.map(&:competitor_registrants).flatten.map(&:user)
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
