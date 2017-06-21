class RegistrantGroupManager
  attr_reader :registrant_group

  def initialize(registrant_group)
    @registrant_group = registrant_group
  end

  def add_member(new_member)
    registrant_group.registrant_group_members.create(registrant: new_member)
  end

  def remove_member(member)
    registrant_group.registrant_group_members.find_by(registrant: member).destroy
  end

  def promote(existing_member)
    member = registrant_group.registrant_group_members.find_by(registrant: existing_member)
    return false unless member

    registrant_group.registrant_group_leaders.create(user: member.user)
  end

  def leave_leader(user)
    registrant_group.registrant_group_leaders.find_by(user: user).destroy
  end
end
