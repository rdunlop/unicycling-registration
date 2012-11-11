class EventChoice < ActiveRecord::Base
  attr_accessible :cell_type, :event_id, :export_name, :label, :multiple_values, :position

  belongs_to :event

  validates :export_name, {:presence => true, :uniqueness => true}
  validates :cell_type, :inclusion => {:in => %w(boolean text multiple), :message => "%{value} must be either 'boolean' or 'text' or 'multiple' or '...'"}

  def choicename
    "choice#{id}"
  end

  def values
    multiple_values.split(%r{,\s*})
  end
end
