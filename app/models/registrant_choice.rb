class RegistrantChoice < ActiveRecord::Base
  attr_accessible :event_choice_id, :registrant_id, :value, :event_category_id

  validates :event_choice_id, :presence => true
  validates :registrant, :presence => true

  has_paper_trail :meta => { :registrant_id => :registrant_id }

  belongs_to :event_choice
  belongs_to :registrant, :inverse_of => :registrant_choices
  belongs_to :event_category # for use when event_choice is 'category' type

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
    elsif event_choice.cell_type == "category"
      self.event_category.to_s unless self.event_category.nil?
    else
      self.value
    end
  end
end
