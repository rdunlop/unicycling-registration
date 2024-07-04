class LodgingRoomOptionPolicy < ApplicationPolicy
  def contact_registrants?
    event_planner? || super_admin?
  end

  class Scope < Scope
    def resolve
      scope.none
    end
  end
end
