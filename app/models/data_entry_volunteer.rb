class DataEntryVolunteer
  include ActiveModel::Validations
  include ActiveModel::Conversion

  attr_accessor :user, :user_id, :competition, :name

  validates :user, presence: true

  delegate :email, to: :user

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
    if self.user_id
      self.user = User.find(user_id)
    else
      self.user ||= User.new
    end
  end


  def save
    begin
      user.update_attributes!(name: name)
      user.add_role(:data_entry_volunteer)
    rescue ActiveRecord::RecordInvalid => invalid
      return false
    end
    true
  end

  delegate :errors, to: :user

  def new_record?
    false
  end

  def to_param
    user.to_param
  end

  def id
    user.id
  end

  def persisted?
    user.persisted?
  end
end
