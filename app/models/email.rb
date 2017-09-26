class Email
  include Virtus.model
  include ActiveModel::AttributeMethods
  include ActiveModel::Validations
  include ActiveModel::Conversion

  attr_accessor :subject, :body
  validates :subject, :body, presence: true

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

  def persisted?
    false
  end
end
