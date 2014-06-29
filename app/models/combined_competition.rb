# == Schema Information
#
# Table name: combined_competitions
#
#  id                            :integer          not null, primary key
#  name                          :string(255)
#  created_at                    :datetime
#  updated_at                    :datetime
#  use_age_group_places          :boolean          default(FALSE)
#  percentage_based_calculations :boolean          default(FALSE)
#

class CombinedCompetition < ActiveRecord::Base

  validates :name, {presence: true, uniqueness: true}

  has_many :combined_competition_entries, dependent: :destroy

  def to_s
    name
  end
end
