shared_context 'can login' do
  def fill_in_login_form
    within('.new_user') do
      fill_in 'Email', with: user.email
      fill_in 'Password', with: user.password
      click_button 'Log in'
    end
  end
end

shared_context 'user is logged in' do
  include_context 'can login'
  before :each do
    visit new_user_session_path
    fill_in_login_form
  end
end

shared_context 'basic event configuration' do
  before :each do
    FactoryGirl.create(:wheel_size_24)
    FactoryGirl.create(:wheel_size_20)
    FactoryGirl.create(:event_configuration, :start_date => Date.today + 6.months, :iuf => true, :usa => false, :test_mode => false)
    FactoryGirl.create(:registration_period, :start_date => Date.today - 1.month, :end_date => Date.today + 1.month)
    FactoryGirl.create(:event, :name => "100m")
  end
end

shared_context 'basic registrant data' do
  before :each do
    fill_in 'registrant_first_name', with: 'Robin'
    fill_in 'registrant_last_name',  with: 'Dunlop'
    select 'May',   :from => 'registrant_birthday_2i'
    select '20',    :from => 'registrant_birthday_3i'
    select '1982',  :from => 'registrant_birthday_1i'
    choose 'Male'
    fill_in 'Address', with: "123 Fake street"
    fill_in "City", with: "Springfield"
    find(:select, 'registrant_contact_detail_attributes_country_residence').first(:option, 'United States').select_option
    #select "United States", :from => "Country of residence"
    fill_in 'Zip', with: '123456'
    fill_in 'registrant_contact_detail_attributes_emergency_name', with: 'John Smith'
    fill_in 'registrant_contact_detail_attributes_emergency_relationship', with: 'friend'
    fill_in 'registrant_contact_detail_attributes_emergency_primary_phone', with: '123-123-1234'
  end
end
