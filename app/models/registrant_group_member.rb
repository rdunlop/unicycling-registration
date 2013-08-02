class RegistrantGroupMember < ActiveRecord::Base
  attr_accessible :registrant_id, :registrant_group_id

  belongs_to :registrant_group
  belongs_to :registrant

  validates :registrant_id, :presence => true
  validates :registrant_group_id, :presence => true
end
