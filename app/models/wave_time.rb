# == Schema Information
#
# Table name: wave_times
#
#  id             :integer          not null, primary key
#  competition_id :integer
#  wave           :integer
#  minutes        :integer
#  seconds        :integer
#  created_at     :datetime
#  updated_at     :datetime
#  scheduled_time :string(255)
#
# Indexes
#
#  index_wave_times_on_competition_id_and_wave  (competition_id,wave) UNIQUE
#

class WaveTime < ActiveRecord::Base
  validates :wave, :competition, :minutes, :seconds, :presence => true
  validates :minutes, :seconds, :numericality => {:greater_than_or_equal_to => 0}, allow_nil: true

  validates :wave, :uniqueness => {:scope => [:competition_id] }

  belongs_to :competition, inverse_of: :wave_times, touch: true

  def total_seconds
    (minutes * 60) + seconds
  end
end
