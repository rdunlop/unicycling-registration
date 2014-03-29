# == Schema Information
#
# Table name: registrant_group_members
#
#  id                  :integer          not null, primary key
#  registrant_id       :integer
#  registrant_group_id :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#

class RegistrantGroupMember < ActiveRecord::Base
  belongs_to :registrant_group, :inverse_of => :registrant_group_members
  belongs_to :registrant

  validates :registrant, :presence => true
  validates :registrant_id, :uniqueness => {:scope => [:registrant_group_id]}
  validates :registrant_group, :presence => true


  def to_s
    registrant_group.to_s
  end
end
