class Email
  include Virtus.model
  include ActiveModel::AttributeMethods
  include ActiveModel::Validations
  include ActiveModel::Conversion

  attr_accessor :subject, :body, :include_my_email, :additional_reply_to_emails

  validates :subject, :body, presence: true

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

  def persisted?
    false
  end

  def include_my_email?
    ActiveModel::Type::Boolean.new.cast(include_my_email)
  end

  def reply_to_emails_to_store(current_user)
    addresses = additional_reply_to_emails.to_s.split(",").map(&:strip).reject(&:blank?)
    addresses << current_user.email if include_my_email?
    addresses.uniq.join(", ")
  end
end
