# == Schema Information
#
# Table name: registrant_group_types
#
#  id                    :integer          not null, primary key
#  source_element_type   :string           not null
#  source_element_id     :integer          not null
#  notes                 :string
#  max_members_per_group :integer
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#

require 'spec_helper'

describe RegistrantGroupTypesController do
  before(:each) do
    @admin_user = FactoryGirl.create(:super_admin_user)
    sign_in @admin_user
  end

  describe "GET index" do
    it "shows all registrant_group_types" do
      registrant_group_type = FactoryGirl.create(:registrant_group_type)
      get :index
      assert_select "li", text: registrant_group_type.source_element.to_s, count: 1
    end
  end
end
