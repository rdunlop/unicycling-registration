module Competeable
  extend ActiveSupport::Concern

  included do
    belongs_to :competitor, :touch => true

    validates :competitor_id, :presence => true

    delegate :competition, to: :competitor
  end

end

