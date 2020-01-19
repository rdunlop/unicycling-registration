require 'spec_helper'

describe ConventionSpecificRulesController do
  before do
    @config = FactoryBot.create(:event_configuration, :with_custom_rules_pdf)
  end

  it "can download the custom config" do
    get :show
    expect(response).to be_redirect
  end
end
