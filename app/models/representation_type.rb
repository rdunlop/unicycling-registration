class RepresentationType
  attr_reader :column

  TYPES = ['state', 'country', 'club'].freeze

  def initialize(object)
    @object = object
  end

  # Translate a title
  def self.description
    I18n.t("activerecord.attributes.representation_type.#{column}")
  end

  def self.column
    EventConfiguration.singleton.representation_type
  end

  def to_s
    @object.public_send(self.class.column)
  end
end
