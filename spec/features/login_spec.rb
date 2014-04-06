require 'spec_helper'

describe 'Logging in to the system' do
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
        visit '/event_configurations'
        expect(current_path).to eq user_registrants_path(user)
        expect(page).to have_content 'You are not authorized to access this page'
      end
    end
  end

  context 'as an admin', login: true do
    let(:user) { FactoryGirl.create :super_admin_user }

    context 'that is not logged in' do
      let(:path) { '/event_configurations' }

      specify 'is redirected to the proper path after logging in' do
        visit path
        expect(current_path).to eq new_user_session_path

        fill_in_login_form

        expect(current_path).to eq path
      end
    end
  end
end
