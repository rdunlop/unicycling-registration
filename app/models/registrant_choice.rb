class RegistrantChoice < ActiveRecord::Base
  attr_accessible :event_choice_id, :registrant_id, :value

  validates :event_choice_id, :presence => true, :uniqueness => {:scope => [:registrant_id]}
  validates :registrant, :presence => true

  has_paper_trail :meta => { :registrant_id => :registrant_id }

  belongs_to :event_choice
  belongs_to :registrant, :inverse_of => :registrant_choices

  def has_value?
    if event_choice.cell_type == "boolean"
      return self.value != "0"
    elsif event_choice.cell_type == "multiple"
      return self.value != ""
    elsif event_choice.cell_type == "category"
      return !self.event_category.nil?
    elsif event_choice.cell_type == "text"
      return self.value != ""
    else
      return false
    end
  end

  def describe_value
    if event_choice.cell_type == "boolean"
      self.value != "0" ? "yes" : "no"
    else
      self.value
    end
  end
end
