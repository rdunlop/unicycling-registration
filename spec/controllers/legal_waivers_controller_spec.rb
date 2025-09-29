require 'spec_helper'

describe LegalWaiversController do
  context "with a waiver pdf" do
    before do
      @config = FactoryBot.create(:event_configuration, :with_waiver_pdf)
    end

    it "can download the waiver" do
      get :show
      expect(response).to be_redirect
    end
  end

  it "raises error if no record found" do
    expect { get :show }.to raise_error(ActiveRecord::RecordNotFound)
  end
end
