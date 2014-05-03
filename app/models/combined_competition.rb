# == Schema Information
#
# Table name: combined_competitions
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class CombinedCompetition < ActiveRecord::Base

  validates :name, {presence: true, uniqueness: true}

  has_many :combined_competition_entries, dependent: :destroy

  def to_s
    name
  end
end
