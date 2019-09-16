# == Schema Information
#
# Table name: refunds
#
#  id          :integer          not null, primary key
#  user_id     :integer
#  refund_date :datetime
#  note        :string
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
  before do
    @user = FactoryBot.create(:super_admin_user)
    sign_in @user
  end

  let(:refund) { FactoryBot.create(:refund) }

  describe "GET show" do
    it "renders" do
      get :show, params: { id: refund.id }
      expect(response).to be_successful
    end
  end
end
