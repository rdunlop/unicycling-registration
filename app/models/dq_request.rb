class DqRequest
  include ActiveModel::Validations
  include ActiveModel::Conversion

  attr_accessor :bib_number, :heat, :lane, :comments, :comments_by
  validates :bib_number, :heat, :lane, :comments, :comments_by, presence: true

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

  def persisted?
    false
  end
end
