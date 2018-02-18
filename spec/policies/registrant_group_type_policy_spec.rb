require "spec_helper"

describe RegistrantGroupTypePolicy do
  let(:super_admin) { FactoryBot.create(:super_admin_user) }

  let(:event_director) { FactoryBot.create(:user) }
  let(:other_event_director) { FactoryBot.create(:user) }
  let(:event) { FactoryBot.create(:event) }

  before do
    event_director.add_role(:director, event)
    other_event_director.add_role(:director, FactoryBot.create(:event))
  end
  let(:registrant_group_type) { FactoryBot.create(:registrant_group_type, source_element: event) }

  subject { described_class }

  permissions :new?, :show?, :index? do
    it "super_admin can access" do
      expect(subject).to permit(super_admin, registrant_group_type)
    end

    it "either director can access" do
      expect(subject).to permit(event_director, registrant_group_type)
      expect(subject).to permit(other_event_director, registrant_group_type)
    end
  end

  permissions :create?, :destroy?, :edit?, :update? do
    it "allows event-director" do
      expect(subject).to permit(event_director, registrant_group_type)
    end

    it "does not allow different-event director" do
      expect(subject).not_to permit(other_event_director, registrant_group_type)
    end
  end
end
