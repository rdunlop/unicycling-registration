class CombinedCompetition < ActiveRecord::Base

  validates :name, {presence: true, uniqueness: true}

  has_many :combined_competition_entries, dependent: :destroy
end
