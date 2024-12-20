require 'spec_helper'

describe ConventionSpecificRulesController do
  context "with a custom rule pdf" do
    before do
      @config = FactoryBot.create(:event_configuration, :with_custom_rules_pdf)
    end

    it "can download the custom config" do
      get :show
      expect(response).to be_redirect
    end
  end

  it "raises error if no record found" do
    expect { get :show }.to raise_error(ActiveRecord::RecordNotFound)
  end
end
