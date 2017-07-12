require 'spec_helper'

describe RegistrantGroupManager do
  let(:registrant_group) { FactoryGirl.create(:registrant_group) }
  let(:manager) { described_class.new(registrant_group) }
  let!(:registrant_group_member) { FactoryGirl.create(:registrant_group_member, registrant_group: registrant_group) }

  describe "#add_member" do
    it "cannot be a member of another group" do
      expect(manager.add_member(registrant_group_member)).to be_falsy
    end

    context "with a limit of 2 members" do
      let(:registrant_group_type) { FactoryGirl.create(:registrant_group_type, max_members_per_group: 2) }
      let(:registrant_group) { FactoryGirl.create(:registrant_group, registrant_group_type: registrant_group_type) }
      let(:registrant) { FactoryGirl.create(:competitor) }
      let(:new_reg_group_member) { registrant_group.registrant_group_members.build(registrant_id: registrant.id) }

      it "can add a 2nd member" do
        expect(manager.add_member(new_reg_group_member)).to be_truthy
      end

      it "cannot exceed the group size limit" do
        FactoryGirl.create(:registrant_group_member, registrant_group: registrant_group)
        expect(manager.add_member(new_reg_group_member)).to be_falsy
      end
    end
  end

  describe "#remove_member" do
    it "removes the member" do
      registrant_group_member
      expect(manager.remove_member(registrant_group_member.registrant)).to be_truthy
    end
  end

  describe "#promote" do
    xit "does not promote non-members"

    it "does promote member" do
      expect do
        manager.promote(registrant_group_member)
      end.to change(RegistrantGroupLeader, :count).by(1)
    end
  end

  describe "remove_leader" do
    let!(:leader) { FactoryGirl.create(:registrant_group_leader, registrant_group: registrant_group) }
    it "cannot remove the last leader" do
      expect(manager.remove_leader(leader)).to be_falsy
    end

    context "with 2 leaders" do
      let!(:other_leader) { FactoryGirl.create(:registrant_group_leader, registrant_group: registrant_group) }

      it "can remove 2nd last leader" do
        expect(manager.remove_leader(other_leader)).to be_truthy
      end
    end
  end
end
