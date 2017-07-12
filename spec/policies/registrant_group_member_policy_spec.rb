require "spec_helper"

describe RegistrantGroupMemberPolicy do
  let(:super_admin) { FactoryGirl.create(:super_admin_user) }

  let(:event_director) { FactoryGirl.create(:user) }
  let(:other_event_director) { FactoryGirl.create(:user) }
  let(:event) { FactoryGirl.create(:event) }

  before do
    event_director.add_role(:director, event)
    other_event_director.add_role(:director, FactoryGirl.create(:event))
  end
  let(:registrant_group_type) { FactoryGirl.create(:registrant_group_type, source_element: event) }
  let(:registrant_group) { FactoryGirl.create(:registrant_group, registrant_group_type: registrant_group_type) }
  let(:group_leader) { FactoryGirl.create(:registrant_group_leader, registrant_group: registrant_group) }
  let(:registrant_group_member) { FactoryGirl.create(:registrant_group_member, registrant_group: registrant_group) }

  subject { described_class }

  permissions :create?, :destroy?, :promote? do
    it "super_admin can access" do
      expect(subject).to permit(super_admin, registrant_group_member)
    end

    it "event director can access" do
      expect(subject).to permit(event_director, registrant_group_member)
    end

    it "other director cannot access" do
      expect(subject).not_to permit(other_event_director, registrant_group_member)
    end

    it "group leader can access" do
      expect(subject).to permit(group_leader.user, registrant_group_member)
    end
  end
end
