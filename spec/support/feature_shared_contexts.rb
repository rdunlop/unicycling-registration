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
    login_as user
    visit '/'
  end
end

shared_context "unpaid registration" do
  let(:competitor) { FactoryGirl.create(:competitor, user: user) }
end

shared_context 'basic event configuration' do |options = {}|
  options.reverse_merge! test_mode: false
  before :each do
    FactoryGirl.create(:wheel_size_16)
    FactoryGirl.create(:wheel_size_20)
    FactoryGirl.create(:wheel_size_24)
    FactoryGirl.create(:event_configuration, start_date: Date.today + 6.months,
                                             iuf: true, usa: false, usa_membership_config: false, test_mode: options[:test_mode], music_submission_end_date: Date.today + 2.months)
    exp_comp = FactoryGirl.create(:expense_item, name: "Early Registration - Competitor", cost: 20.00)
    exp_noncomp = FactoryGirl.create(:expense_item, name: "Early Registration - NonCompetitor", cost: 11.00)
    FactoryGirl.create(:registration_period, :current, start_date: Date.today - 1.month, end_date: Date.today + 1.month, competitor_expense_item: exp_comp, noncompetitor_expense_item: exp_noncomp)
    FactoryGirl.create(:event, name: "100m")
  end
end

shared_context "freestyle_event" do |options = {}|
  before :each do
    event = FactoryGirl.create(:event, name: options[:name])
    competition = FactoryGirl.create(:competition, event: event, name: options[:name])
    FactoryGirl.create(:event_competitor, competition: competition)
    reg = Registrant.first
    reg.first_name = "Robin"
    reg.last_name = "Robin"
    reg.save
  end
end

shared_context "points_event" do |options = {}|
  before :each do
    event = FactoryGirl.create(:event, name: options[:name])
    competition = FactoryGirl.create(:ranked_competition, event: event, name: options[:name], start_data_type: 'One Data Per Line')
    FactoryGirl.create(:event_competitor, competition: competition)
    reg = Registrant.first
    reg.first_name = "Robin"
    reg.last_name = "Robin"
    reg.save
  end
end

shared_context "judge_is_assigned_to_competition" do |options = {}|
  before :each do
    competition = Competition.first
    judge_user = User.find_by(name: options[:user_name])
    judge = FactoryGirl.create(:judge, competition: competition, user: judge_user)
    jt = judge.judge_type
    jt.name = "Presentation"
    jt.save
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

shared_context 'paid expense item' do
  before :each do
    pd = FactoryGirl.create(:payment_detail, registrant: competitor)
    payment = pd.payment
    payment.completed = true
    payment.save
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
    select 'May',   from: 'registrant_birthday_2i'
    select '20',    from: 'registrant_birthday_3i'
    select '1982',  from: 'registrant_birthday_1i'
    choose 'Male'
    sleep 1 # needed or else the feature spec fails to register that the "Male" has been selected.
  end
end
shared_context "basic address data" do
  before :each do
    fill_in 'Address', with: "123 Fake street"
    fill_in "City", with: "Springfield"
    find(:select, 'registrant_contact_detail_attributes_country_residence').first(:option, 'United States').select_option
    # select "United States", :from => "Country of residence"
    # do we need to add state here in the same way as country?
    fill_in 'Zip', with: '123456'
    fill_in 'registrant_contact_detail_attributes_emergency_name', with: 'John Smith'
    fill_in 'registrant_contact_detail_attributes_emergency_relationship', with: 'friend'
    fill_in 'registrant_contact_detail_attributes_emergency_primary_phone', with: '123-123-1234'
  end
end
