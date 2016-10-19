# == Schema Information
#
# Table name: combined_competitions
#
#  id                   :integer          not null, primary key
#  name                 :string(255)
#  created_at           :datetime
#  updated_at           :datetime
#  use_age_group_places :boolean          default(FALSE), not null
#  tie_break_by_firsts  :boolean          default(TRUE), not null
#  calculation_mode     :string           not null
#
# Indexes
#
#  index_combined_competitions_on_name  (name) UNIQUE
#

class CombinedCompetition < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  validates :calculation_mode, presence: true
  CALCULATION_MODES = ['default', 'percentage', 'average_speed'].freeze
  validates :calculation_mode, inclusion: { in: CALCULATION_MODES }

  has_many :combined_competition_entries, -> {order("combined_competition_entries.id") }, dependent: :destroy
  has_one :competition

  def to_s
    name
  end

  def percentage_based_calculations?
    calculation_mode == 'percentage'
  end

  def average_speed_calculation?
    calculation_mode == 'average_speed'
  end

  def requires_per_place_points?
    calculation_mode == 'default' || calculation_mode == 'percentage'
  end
end
