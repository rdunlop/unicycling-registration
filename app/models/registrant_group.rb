# == Schema Information
#
# Table name: registrant_groups
#
#  id                       :integer          not null, primary key
#  name                     :string
#  created_at               :datetime
#  updated_at               :datetime
#  registrant_group_type_id :integer
#
# Indexes
#
#  index_registrant_groups_on_registrant_group_type_id  (registrant_group_type_id)
#

class RegistrantGroup < ApplicationRecord
  belongs_to :registrant_group_type

  has_many :registrant_group_members, dependent: :destroy, inverse_of: :registrant_group
  has_many :registrant_group_leaders, dependent: :destroy, inverse_of: :registrant_group
  has_many :registrants, through: :registrant_group_members

  validates :name, uniqueness: { scope: :registrant_group_type_id }, allow_blank: true

  def sorted_registrants
    registrants.sort{|a, b| a.contact_detail.address <=> b.contact_detail.address }
  end

  def to_s
    name
  end

  def leaders
    registrant_group_leaders.map(&:user)
  end
end
