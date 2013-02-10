class EventChoice < ActiveRecord::Base
  attr_accessible :cell_type, :event_id, :export_name, :label, :multiple_values, :position

  belongs_to :event
  has_many :registrant_choices, :dependent => :destroy

  validates :export_name, {:presence => true, :uniqueness => true}
  validates :cell_type, :inclusion => {:in => %w(boolean text multiple), :message => "%{value} must be either 'boolean' or 'text' or 'multiple' or '...'"}
  validate :position_1_must_be_boolean
  validates :position, :uniqueness => {:scope => [:event_id]}

  def choicename
    "choice#{id}"
  end

  def values
    multiple_values.split(%r{,\s*})
  end

  def position_1_must_be_boolean
    if self.position == 1 and self.cell_type != "boolean"
      errors[:cell_type] << "Only 'boolean' types are allowed in position 1"
    end
  end

  def to_s
    self.event.to_s + " - " + self.export_name
  end
end
