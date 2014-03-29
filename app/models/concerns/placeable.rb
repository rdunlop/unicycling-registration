# These can be used with the PlaceCalculator
# to relatively position results
# They should implement a 'disqualified' method and a 'result' method
module Placeable
  extend ActiveSupport::Concern

  included do
    delegate :gender, :ineligible, :age_group_entry_description, to: :competitor
  end

  def result
    raise NotImplementedError
  end
end

