module Judgeable
  extend ActiveSupport::Concern
  include Competeable

  included do
    belongs_to :judge, touch: true

    validates :judge_id, presence: true, uniqueness: {scope: [:competitor_id]}

    delegate :user, to: :judge
  end
end
