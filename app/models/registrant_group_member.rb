class RegistrantGroupMember < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection
  attr_accessible :registrant_id, :registrant_group_id

  belongs_to :registrant_group, :inverse_of => :registrant_group_members
  belongs_to :registrant

  validates :registrant, :presence => true
  validates :registrant_id, :uniqueness => {:scope => [:registrant_group_id]}
  validates :registrant_group, :presence => true


  def to_s
    registrant_group.to_s
  end
end
