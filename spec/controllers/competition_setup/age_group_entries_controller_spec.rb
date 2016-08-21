require 'spec_helper'

describe CompetitionSetup::AgeGroupEntriesController do
  before(:each) do
    sign_in FactoryGirl.create(:super_admin_user)
  end

  describe "PUT update_row_order" do
    let(:age_group_type) { FactoryGirl.create(:age_group_type) }
    let!(:age_group_entry_1) { FactoryGirl.create(:age_group_entry, age_group_type: age_group_type) }
    let!(:age_group_entry_2) { FactoryGirl.create(:age_group_entry, age_group_type: age_group_type) }

    it "updates the order" do
      put :update_row_order, id: age_group_entry_1.to_param, row_order_position: 1
      expect(age_group_entry_2.reload.position).to eq(1)
      expect(age_group_entry_1.reload.position).to eq(2)
    end
  end
end
