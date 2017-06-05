# == Schema Information
#
# Table name: registrant_group_leaders
#
#  id                  :integer          not null, primary key
#  registrant_group_id :integer          not null
#  user_id             :integer          not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
# Indexes
#
#  index_registrant_group_leaders_on_registrant_group_id  (registrant_group_id)
#  index_registrant_group_leaders_on_user_id              (user_id)
#  registrant_group_leaders_uniq                          (registrant_group_id,user_id) UNIQUE
#

class RegistrantGroupLeader < ApplicationRecord
  belongs_to :registrant_group, inverse_of: :registrant_group_leaders
  belongs_to :user

  validates :registrant_group_id, uniqueness: {scope: [:user_id]}
  validates :registrant_group, presence: true
  validates :user, presence: true
end
