class MissingAgeGroupEntryWarningPolicy < ApplicationPolicy
  def show?
    director?(record.competition.event) || competition_admin? || super_admin?
  end
end
