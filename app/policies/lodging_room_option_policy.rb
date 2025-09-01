class LodgingRoomOptionPolicy < ApplicationPolicy
  def contact_registrants?
    event_planner? || super_admin?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if super_admin?
        scope
      else
        scope.none
      end
    end
  end
end
