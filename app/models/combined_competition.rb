# == Schema Information
#
# Table name: combined_competitions
#
#  id                            :integer          not null, primary key
#  name                          :string(255)
#  created_at                    :datetime
#  updated_at                    :datetime
#  use_age_group_places          :boolean          default(FALSE), not null
#  percentage_based_calculations :boolean          default(FALSE), not null
#
# Indexes
#
#  index_combined_competitions_on_name  (name) UNIQUE
#

class CombinedCompetition < ActiveRecord::Base
  validates :name, presence: true, uniqueness: true

  has_many :combined_competition_entries, -> {order("combined_competition_entries.id") }, dependent: :destroy
  has_one :competition

  def to_s
    name
  end
end
