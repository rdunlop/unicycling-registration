class DQRequest
  include ActiveModel::Validations
  include ActiveModel::Conversion

  attr_accessor :bib_number, :heat, :comments, :comments_by
  validates_presence_of :bib_number, :heat, :comments, :comments_by

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

  def persisted?
    false
  end
end
