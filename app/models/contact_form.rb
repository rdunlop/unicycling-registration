class ContactForm
  include ActiveModel::Validations
  include ActiveModel::Conversion

  attr_accessor :feedback
  validates_presence_of :feedback

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

  def username=(value)
    @username = value
  end

  def username
    @username || "not-signed-in"
  end

  def registrants=(value)
    @registrants = value
  end

  def registrants
    @registrants || "unknown"
  end

  def update_from_user(user)
    self.username = user.email
    self.registrants = user.registrants.first.name if user.registrants.count > 0
  end

  def persisted?
    false
  end
end
