# == Schema Information
#
# Table name: lodging_package_days
#
#  id                 :integer          not null, primary key
#  lodging_package_id :integer          not null
#  lodging_day_id     :integer          not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
# Indexes
#
#  index_lodging_package_days_on_lodging_day_id      (lodging_day_id)
#  index_lodging_package_days_on_lodging_package_id  (lodging_package_id)
#  lodging_package_unique                            (lodging_package_id,lodging_day_id) UNIQUE
#

class LodgingPackageDay < ApplicationRecord
  validates :lodging_package, :lodging_day, presence: true

  belongs_to :lodging_package, inverse_of: :lodging_package_days
  belongs_to :lodging_day
end
