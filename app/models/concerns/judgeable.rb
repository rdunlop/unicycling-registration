module Judgeable
  extend ActiveSupport::Concern
  include Competeable

  included do
    belongs_to :judge, touch: true

    validates :judge_id, presence: true
    validates :judge_id, uniqueness: {scope: [:competitor_id]}, on: :create

    delegate :user, to: :judge
  end
end
