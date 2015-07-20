require 'spec_helper'

describe 'With an Externally Ranked Competition' do
  # let!(:user) { FactoryGirl.create(:payment_admin) }
  let(:user) { FactoryGirl.create(:super_admin_user) }
  include_context 'user is logged in'
  include_context 'basic event configuration'

  before :each do
    @competition = FactoryGirl.create(:ranked_competition)
  end

  it "can import csv data" do
    visit display_csv_user_competition_import_results_path(User.first, @competition)
    expect(page).to have_content 'Import CSV Data'
  end
end
