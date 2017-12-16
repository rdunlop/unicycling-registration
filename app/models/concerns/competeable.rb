module Competeable
  extend ActiveSupport::Concern

  included do
    belongs_to :competitor, touch: true

    validates :competitor_id, presence: true

    after_save    :update_last_data_update_time
    after_destroy :update_last_data_update_time

    delegate :competition, to: :competitor
  end

  def update_last_data_update_time
    Result.update_last_data_update_time(competition, Time.current)
  end
end
