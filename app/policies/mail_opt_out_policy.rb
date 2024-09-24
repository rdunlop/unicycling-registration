class MailOptOutPolicy < ApplicationPolicy
  def index?
    event_planner? || super_admin?
  end

  # Can this user re-subscribe this user?
  # Yes if they are either the self-same user, or a super_admin
  def subscribe?
    return true if super_admin?

    possible_emails = [user.email, user.registrants.map(&:email)].flatten

    record.email.in?(possible_emails)
  end
end
