# These can be used with the PlaceCalculator
# to relatively position results
# They should implement a 'disqualified' method and a 'result' method
module Placeable
  extend ActiveSupport::Concern

  # XXX get rid of this concern?
  included do
    delegate :gender, :ineligible, :age_group_entry_description, to: :competitor
  end

  def result
    raise NotImplementedError
  end
end

