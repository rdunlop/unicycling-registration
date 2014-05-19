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

shared_context "unpaid registration" do
  let(:competitor) { FactoryGirl.create(:competitor, user: user) }
end

shared_context 'basic event configuration' do |options = {}|
  options.reverse_merge! test_mode: false
  before :each do
    FactoryGirl.create(:wheel_size_24)
    FactoryGirl.create(:wheel_size_20)
    FactoryGirl.create(:event_configuration, :start_date => Date.today + 6.months,
                       :iuf => true, :usa => false, :test_mode => options[:test_mode], :music_submission_end_date => Date.today + 2.months)
    exp_comp = FactoryGirl.create(:expense_item, name: "Early Registration - Competitor", cost: 20.00)
    exp_noncomp = FactoryGirl.create(:expense_item, name: "Early Registration - NonCompetitor", cost: 11.00)
    FactoryGirl.create(:registration_period, :start_date => Date.today - 1.month, :end_date => Date.today + 1.month, competitor_expense_item: exp_comp, noncompetitor_expense_item: exp_noncomp)
    FactoryGirl.create(:event, :name => "100m")
  end
end

shared_context 'optional expense_item' do |options = {}|
  options.reverse_merge! cost: 15, has_details: false, details: nil
  before :each do
    @ei = FactoryGirl.create(:expense_item, name: "USA Individual Membership", has_details: options[:has_details], cost: options[:cost])
    competitor.registrant_expense_items.create expense_item: @ei, system_managed: false, details: options[:details]
    competitor.reload
  end
end

shared_context 'optional expense_item with details' do |options = {}|
  options.reverse_merge! has_details: true, details: ""
  include_context 'optional expense_item', options
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
