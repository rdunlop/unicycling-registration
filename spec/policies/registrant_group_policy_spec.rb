require "spec_helper"

describe RegistrantGroupPolicy do
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

  subject { described_class }

  permissions :new?, :create?, :index? do
    it "super_admin can access" do
      expect(subject).to permit(super_admin, registrant_group)
    end

    it "either director can access" do
      expect(subject).to permit(event_director, registrant_group)
      expect(subject).to permit(other_event_director, registrant_group)
    end
  end

  permissions :edit?, :update?, :destroy? do
    it "super_admin can access" do
      expect(subject).to permit(super_admin, registrant_group)
    end
    it "allows event-director" do
      expect(subject).to permit(event_director, registrant_group)
    end

    it "does not allow different-event director" do
      expect(subject).not_to permit(other_event_director, registrant_group)
    end

    it "allows group leader" do
      expect(subject).to permit(group_leader.user, registrant_group)
    end
  end
end
