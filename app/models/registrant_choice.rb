class RegistrantChoice < ActiveRecord::Base
  attr_accessible :event_choice_id, :registrant_id, :value

  validates :event_choice_id, :presence => true
  validates :registrant, :presence => true

  has_paper_trail :meta => { :registrant_id => :registrant_id }

  belongs_to :event_choice
  belongs_to :registrant, :inverse_of => :registrant_choices
end
