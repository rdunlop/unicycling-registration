class DataEntryVolunteer
  include ActiveModel::Validations
  include ActiveModel::Conversion

  attr_accessor :user, :user_id, :competition, :name

  validates :user, presence: true
  validates :name, presence: true

  delegate :email, to: :user

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
    if user_id
      self.user = User.find(user_id)
    else
      self.user ||= User.new
    end
  end

  def save
    return false unless valid?
    begin
      user.confirm! unless user.confirmed?
      user.update_attributes!(name: name)
      user.add_role(:data_entry_volunteer)
    rescue ActiveRecord::RecordInvalid
      return false
    end
    true
  end

  delegate :errors, to: :user

  def new_record?
    true
  end

  delegate :to_param, to: :user

  delegate :id, to: :user

  def persisted?
    false
  end
end
