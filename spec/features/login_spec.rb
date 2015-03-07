require 'spec_helper'

describe 'Logging in to the system' do
  include_context 'basic event configuration'
  include_context 'can login'

  context 'as a normal user' do
    let(:user) { FactoryGirl.create :user }

    context 'that has logged in' do
      before :each do
        visit new_user_session_path
        fill_in_login_form
      end

      specify 'can create new competitor' do
        expect(page).to have_content 'Create New Competitor'
      end

      specify 'is not allowed to event_configuration' do
        visit '/convention_setup'
        expect(current_path).to eq user_registrants_path(user)
        expect(page).to have_content 'You are not authorized to access this page'
      end
    end
  end
end
