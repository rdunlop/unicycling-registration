module Judgeable
  extend ActiveSupport::Concern
  include Competeable

  included do
    belongs_to :judge

    validates :judge_id, :presence => true, :uniqueness => {:scope => [:competitor_id]}

    delegate :user, to: :judge
  end

  # determining the place points for this score (by-judge)
  def tied
    judge.competition.tied(self)
  end
end

