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
#  scheduled_time :string(255)
#
# Indexes
#
#  index_heat_times_on_competition_id_and_heat  (competition_id,heat) UNIQUE
#

class HeatTime < ActiveRecord::Base
  validates :heat, :competition, :minutes, :seconds, :presence => true
  validates :minutes, :seconds, :numericality => {:greater_than_or_equal_to => 0}, allow_nil: true

  validates :heat, :uniqueness => {:scope => [:competition_id] }

  belongs_to :competition, inverse_of: :heat_times, touch: true

  def total_seconds
    (minutes * 60) + seconds
  end
end
