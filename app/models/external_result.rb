class ExternalResult < ActiveRecord::Base
  validates :competitor_id, :rank, :presence => true
  belongs_to :competitor


  def competition
    competitor.competition
  end
end
