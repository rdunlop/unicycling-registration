class EventChoice < ActiveRecord::Base
  attr_accessible :cell_type, :event_id, :export_name, :label, :multiple_values, :position, :autocomplete

  belongs_to :event
  has_many :registrant_choices, :dependent => :destroy

  validates :label, {:presence => true}
  validates :export_name, {:presence => true, :uniqueness => true}
  validates :cell_type, :inclusion => {:in => %w(boolean text multiple category), :message => "%{value} must be either 'boolean' or 'text', 'multiple' or 'category'"}
  validate :position_1_must_be_boolean
  validates :position, :uniqueness => {:scope => [:event_id]}
  validates :autocomplete, :inclusion => {:in => [true, false] } # because it's a boolean

  after_initialize :init

  def init
    self.autocomplete = false if self.autocomplete.nil?
  end

  def choicename
    "choice#{id}"
  end

  def values
    if cell_type == "category"
      event.event_categories.map { |ec| ec.name }
    else
      multiple_values.split(%r{,\s*})
    end
  end

  def position_1_must_be_boolean
    if self.position == 1 and self.cell_type != "boolean"
      errors[:cell_type] << "Only 'boolean' types are allowed in position 1"
    end
  end

  def unique_values
    self.registrant_choices.map{|rc| rc.value}.uniq
  end

  def to_s
    self.event.to_s + " - " + self.export_name
  end
end
