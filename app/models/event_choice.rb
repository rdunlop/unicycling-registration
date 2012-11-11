class EventChoice < ActiveRecord::Base
  attr_accessible :cell_type, :event_id, :export_name, :label, :multiple_values, :position

  belongs_to :event

  validates :export_name, {:presence => true, :uniqueness => true}
  validates :cell_type, :inclusion => {:in => %w(boolean), :message => "%{value} must be either 'boolean' or '...'"}


  def choicename
    "choice#{id}"
  end
end
