require 'spec_helper'
require 'request_helper'

RSpec.describe Admin::PermissionsController do
  before(:each) do
    @super_user = FactoryGirl.create(:super_admin_user)
    login @super_user
  end

  it "renders index" do
    get "/permissions"
    expect(response).to render_template(:index)
  end
end
