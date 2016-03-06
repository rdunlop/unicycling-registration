# == Schema Information
#
# Table name: refunds
#
#  id          :integer          not null, primary key
#  user_id     :integer
#  refund_date :datetime
#  note        :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#  percentage  :integer          default(100)
#
# Indexes
#
#  index_refunds_on_user_id  (user_id)
#

require 'spec_helper'

describe RefundsController do
  before(:each) do
    @user = FactoryGirl.create(:super_admin_user)
    sign_in @user
  end

  let(:refund) { FactoryGirl.create(:refund) }

  describe "GET show" do
    it "renders" do
      get :show, id: refund.id
      expect(response).to be_success
    end
  end
end
