# == Schema Information
#
# Table name: age_group_entries
#
#  id                :integer          not null, primary key
#  age_group_type_id :integer
#  short_description :string(255)
#  start_age         :integer
#  end_age           :integer
#  gender            :string(255)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  wheel_size_id     :integer
#  position          :integer
#
# Indexes
#
#  index_age_group_entries_age_group_type_id  (age_group_type_id)
#  index_age_group_entries_wheel_size_id      (wheel_size_id)
#

class HeatTime < ActiveRecord::Base
  validates :heat, :competition, :minutes, :seconds, :presence => true
  validates :minutes, :seconds, :numericality => {:greater_than_or_equal_to => 0}, allow_nil: true

  belongs_to :competition, inverse_of: :heat_times

  def total_seconds
    (minutes * 60) + seconds
  end
end
