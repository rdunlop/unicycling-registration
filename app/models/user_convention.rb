# == Schema Information
#
# Table name: user_conventions
#
#  id                        :integer          not null, primary key
#  user_id                   :integer          not null
#  legacy_user_id            :integer
#  subdomain                 :string           not null
#  legacy_encrypted_password :string(255)
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#

class UserConvention < ApplicationRecord
  validates :user_id, presence: true
  validates :subdomain, presence: true

  belongs_to :user
end
