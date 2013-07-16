class Email
  include ActiveModel::Validations
  include ActiveModel::Conversion

  attr_accessor :subject, :body, :email_addresses
  validates_presence_of :subject, :body

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

  def email_addresses=(value)
    @email_addresses = value
  end

  def email_addresses
    @email_addresses
  end

  def subject=(value)
    @subject = value
  end

  def subject
    @subject
  end

  def body=(value)
    @body = value
  end

  def body
    @body
  end

  def persisted?
    false
  end
end
