class DQRequest
  include ActiveModel::Validations
  include ActiveModel::Conversion

  attr_accessor :bib_number, :heat, :comments
  validates_presence_of :bib_number
  validates_presence_of :heat

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

  def persisted?
    false
  end
end
