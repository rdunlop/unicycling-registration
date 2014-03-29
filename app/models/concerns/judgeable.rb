module Judgeable
  extend ActiveSupport::Concern

  included do
    belongs_to :judge
    belongs_to :competitor

    validates :judge_id, :presence => true, :uniqueness => {:scope => [:competitor_id]}
    validates :competitor_id, :presence => true

    delegate :user, to: :judge
  end

  # determining the place points for this score (by-judge)
  def tied
    judge.competition.tied(self)
  end
end

