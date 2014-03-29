module Judgeable
  extend ActiveSupport::Concern

  included do
    belongs_to :judge
    belongs_to :competitor

    validates :judge_id, :presence => true, :uniqueness => {:scope => [:competitor_id]}
    validates :competitor_id, :presence => true
  end

end
