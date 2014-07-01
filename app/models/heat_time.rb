# == Schema Information
#
# Table name: heat_times
#
#  id             :integer          not null, primary key
#  competition_id :integer
#  heat           :integer
#  minutes        :integer
#  seconds        :integer
#  created_at     :datetime
#  updated_at     :datetime
#

class HeatTime < ActiveRecord::Base
  validates :heat, :competition, :minutes, :seconds, :presence => true
  validates :minutes, :seconds, :numericality => {:greater_than_or_equal_to => 0}, allow_nil: true

  belongs_to :competition, inverse_of: :heat_times

  def total_seconds
    (minutes * 60) + seconds
  end
end
