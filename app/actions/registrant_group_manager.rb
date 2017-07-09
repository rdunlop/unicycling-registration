class RegistrantGroupManager
  attr_reader :registrant_group

  def initialize(registrant_group)
    @registrant_group = registrant_group
    @errors = []
  end

  def errors
    @errors.join(", ")
  end

  def add_member(new_registrant_group_member)
    max_members = registrant_group.registrant_group_type.max_members_per_group.to_i
    if max_members > 0 && registrant_group.registrant_group_members.count >= max_members
      @errors << "Unable to add more than #{max_members} to this group"
      return false
    end

    if registrant_group != new_registrant_group_member.registrant_group
      @errors << "Not-matching group"
      return false
    end
    registrant = new_registrant_group_member.registrant
    existing_membership = registrant_group.registrant_group_type.registrant_group_members.merge(registrant.registrant_group_members)
    if existing_membership.any?
      existing_groups = existing_membership.map(&:registrant_group)
      @errors << "Registrant is not allowed to be in more than 1 group (#{existing_groups.map(&:name)})"
      return false
    end

    new_registrant_group_member.save
  end

  def remove_member(member)
    registrant_group.registrant_group_members.find_by(registrant: member).destroy
  end

  def promote(existing_member)
    member = registrant_group.registrant_group_members.find_by(registrant: existing_member.registrant)
    unless member
      @errors << "Member not found"
      return false
    end

    registrant_group.registrant_group_leaders.create(user: existing_member.registrant.user)
  end

  def remove_leader(registrant_group_leader)
    if registrant_group.registrant_group_leaders.count == 1
      @errors << "Unable to remove last leader from a group"
      return false
    end
    registrant_group_leader.destroy
  end
end
