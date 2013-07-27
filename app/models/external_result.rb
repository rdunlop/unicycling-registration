class ExternalResult < ActiveRecord::Base
  attr_accessible :competitor_id, :details, :rank

  validates :competitor_id, :details, :rank, :presence => true
  belongs_to :competitor


  def competition
    competitor.competition
  end
end
