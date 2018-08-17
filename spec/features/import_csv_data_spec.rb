require 'spec_helper'

describe 'With an Externally Ranked Competition' do
  # let!(:user) { FactoryBot.create(:payment_admin) }
  let(:user) { FactoryBot.create(:super_admin_user) }

  include_context 'user is logged in'
  include_context 'basic event configuration'

  before do
    @competition = FactoryBot.create(:ranked_competition)
  end

  it "can import csv data" do
    visit display_csv_user_competition_import_results_path(User.first, @competition)
    expect(page).to have_content 'CSV Import'
  end
end
