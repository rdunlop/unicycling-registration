class Email
  include Virtus.model
  include ActiveModel::AttributeMethods
  include ActiveModel::Validations
  include ActiveModel::Conversion

  attribute :confirmed_accounts, Boolean
  attribute :paid_reg_accounts, Boolean
  attribute :unpaid_reg_accounts, Boolean
  attribute :no_reg_accounts, Boolean
  attribute :non_confirmed_organization_members, Boolean
  attribute :competition_id, Array
  attribute :category_id, Integer
  attribute :event_id, Integer
  attribute :expense_item_id, Integer

  attr_accessor :subject, :body
  validates :subject, :body, presence: true

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
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
    elsif non_confirmed_organization_members
      "User Accounts with Registrants who are not Unicycling-Organization-Members"
    elsif competitions.any?
      "Emails of users/registrants associated with #{competitions.map(&:to_s).join(' ')}"
    elsif category_id.present?
      "Emails of users/registrants associated with any competition in #{category}"
    elsif event_id.present?
      "Emails of users/registrants Signed up for the Event: #{event}"
    elsif expense_item_id.present?
      "Emails of users/registrants who have Paid for #{expense_item}"
    else
      "Unknown"
    end
  end

  def filtered_user_emails
    if filtered_users.any?
      filtered_users.map(&:email).compact.uniq
    else
      []
    end
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
    elsif non_confirmed_organization_members
      Registrant.where(registrant_type: ["competitor", "noncompetitor"]).active_or_incomplete.all.reject(&:organization_membership_confirmed?).map(&:user).compact.uniq
    elsif competitions.any?
      competitions.map(&:registrants).flatten.map(&:user)
    elsif category_id.present?
      category.events.map(&:competitor_registrants).flatten.map(&:user)
    elsif event_id.present?
      event.registrant_event_sign_ups.signed_up.map(&:registrant).map(&:user).uniq
    elsif expense_item_id.present?
      expense_item.paid_items.map(&:registrant).map(&:user).uniq
    else
      []
    end
  end

  def filtered_registrant_emails
    if competition_id.any?
      competitions.map(&:registrants).flatten.map(&:contact_detail).compact.map(&:email).compact.uniq
    elsif category_id.present?
      category.events.map(&:competitor_registrants).flatten.map(&:contact_detail).compact.map(&:email).compact.uniq
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

  private

  def competitions
    return @competitions if @competitions

    @competitions = []
    if competition_id.present?
      competition_id.each do |cid|
        @competitions << Competition.find(cid) if cid.present?
      end
    end

    @competitions
  end

  def category
    Category.find(category_id) if category_id.present?
  end

  def event
    Event.find(event_id) if event_id.present?
  end

  def expense_item
    ExpenseItem.find(expense_item_id) if expense_item_id.present?
  end
end
