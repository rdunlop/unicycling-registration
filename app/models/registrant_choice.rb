class RegistrantChoice < ActiveRecord::Base
  attr_accessible :event_choice_id, :registrant_id, :value

  validates :event_choice_id, :presence => true
  validates :registrant_id, :presence => true

  belongs_to :event_choice
  belongs_to :registrant
end
