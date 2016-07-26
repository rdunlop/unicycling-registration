# == Schema Information
#
# Table name: event_configurations
#
#  id                                            :integer          not null, primary key
#  event_url                                     :string(255)
#  start_date                                    :date
#  contact_email                                 :string(255)
#  artistic_closed_date                          :date
#  standard_skill_closed_date                    :date
#  event_sign_up_closed_date                     :date
#  created_at                                    :datetime
#  updated_at                                    :datetime
#  test_mode                                     :boolean          default(FALSE), not null
#  comp_noncomp_url                              :string(255)
#  standard_skill                                :boolean          default(FALSE), not null
#  usa                                           :boolean          default(FALSE), not null
#  iuf                                           :boolean          default(FALSE), not null
#  currency_code                                 :string(255)
#  rulebook_url                                  :string(255)
#  style_name                                    :string(255)
#  custom_waiver_text                            :text
#  music_submission_end_date                     :date
#  artistic_score_elimination_mode_naucc         :boolean          default(TRUE), not null
#  logo_file                                     :string(255)
#  max_award_place                               :integer          default(5)
#  display_confirmed_events                      :boolean          default(FALSE), not null
#  spectators                                    :boolean          default(FALSE), not null
#  paypal_account                                :string(255)
#  waiver                                        :string(255)      default("none")
#  validations_applied                           :integer
#  italian_requirements                          :boolean          default(FALSE), not null
#  rules_file_name                               :string(255)
#  accept_rules                                  :boolean          default(FALSE), not null
#  paypal_mode                                   :string(255)      default("disabled")
#  offline_payment                               :boolean          default(FALSE), not null
#  enabled_locales                               :string           not null
#  comp_noncomp_page_id                          :integer
#  under_construction                            :boolean          default(TRUE), not null
#  noncompetitors                                :boolean          default(TRUE), not null
#  volunteer_option                              :string           default("generic"), not null
#  age_calculation_base_date                     :date
#  organization_membership_type                  :string
#  request_address                               :boolean          default(TRUE), not null
#  request_emergency_contact                     :boolean          default(TRUE), not null
#  request_responsible_adult                     :boolean          default(TRUE), not null
#  registrants_should_specify_default_wheel_size :boolean          default(TRUE), not null
#  add_event_end_date                            :datetime
#

require 'spec_helper'

# so that I can test print_item_cost_currency
include ApplicationHelper

describe EventConfiguration do
  before(:each) do
    @ev = EventConfiguration.singleton
    @ev.assign_attributes(FactoryGirl.attributes_for(:event_configuration, standard_skill_closed_date: Date.new(2013, 5, 5)))
  end

  it "is valid from factoryGirl" do
    expect(@ev.valid?).to eq(true)
  end

  it "has a short name" do
    @ev.short_name = nil
    @ev.apply_validation(:name_logo)
    expect(@ev.valid?).to eq(false)
  end

  it "does not allows a blank style_name" do
    @ev.style_name = nil
    @ev.apply_validation(:base_settings)
    expect(@ev.valid?).to eq(false)
  end

  it "doesn't allow an unknown currency code" do
    @ev.currency_code = "Robin"
    expect(@ev).to be_invalid
  end

  it { expect(@ev).to validate_inclusion_of(:organization_membership_type).in_array(EventConfiguration.organization_membership_types) }
  it { should allow_value(nil).for(:organization_membership_type) }
  it { should allow_value("").for(:organization_membership_type) }

  context "when in EUR format" do
    before :each do
      @ev.update_attribute(:currency_code, "EUR")
    end

    it "returns the EUR symbol" do
      expect(@ev.currency_unit).to eq("€")
    end

    it "converts from EUR to Symbol" do
      expect(print_item_cost_currency(10.to_money)).to eq("10.00€")
    end
  end

  it "has a list of style_names" do
    expect(EventConfiguration.style_names.count).to be > 0
  end

  it "style_name must be a valid_style_name" do
    @ev.style_name = "fake"
    @ev.apply_validation(:base_settings)
    expect(@ev.valid?).to eq(false)

    @ev.style_name = EventConfiguration.style_names.first[1]
    expect(@ev.valid?).to eq(true)
  end

  it "has a style_name even without having any entries" do
    expect(EventConfiguration.new.style_name).to eq("base_green_blue")
  end

  it "has a long name" do
    @ev.long_name = nil
    @ev.apply_validation(:name_logo)
    expect(@ev.valid?).to eq(false)
  end

  it "event_url can be nil" do
    @ev.event_url = nil
    @ev.apply_validation(:name_logo)
    expect(@ev.valid?).to eq(true)
  end

  it "event_url must be url" do
    @ev.event_url = "hello"
    expect(@ev.valid?).to eq(false)

    @ev.event_url = "http://www.google.com"
    expect(@ev.valid?).to eq(true)
  end

  it "can have a blank comp_noncomp_url" do
    @ev.comp_noncomp_url = ""
    expect(@ev.valid?).to eq(true)
  end

  it "cannot have both url and page" do
    @ev.comp_noncomp_url = "http://www.google.com"
    @ev.comp_noncomp_page_id = FactoryGirl.create(:page).id
    expect(@ev).to be_invalid
  end

  it "Can have a info page" do
    @ev.comp_noncomp_page_id = FactoryGirl.create(:page).id
    expect(@ev).to be_valid
  end

  it "requires that the artistic closed date be before the event closed date" do
    @ev.artistic_closed_date = 1.month.ago
    @ev.event_sign_up_closed_date = 1.month.ago + 1.day
    expect(@ev).to be_valid
  end

  it "doesn't allow the artistic date to be after the event closed date" do
    @ev.artistic_closed_date = 1.month.ago
    @ev.event_sign_up_closed_date = 2.months.ago
    expect(@ev).to be_invalid
  end

  it "allows the artistic closed date to be nil" do
    @ev.artistic_closed_date = nil
    @ev.event_sign_up_closed_date = 2.months.ago
    expect(@ev).to be_valid

    @ev.event_sign_up_closed_date = nil
    expect(@ev).to be_valid
  end

  it "must have a test_mode" do
    @ev.test_mode = nil
    @ev.apply_validation(:important_dates)
    expect(@ev.valid?).to eq(false)
  end

  describe "#effective_age_calculation_base_date" do
    it "has an effective_age_calculation_base_date" do
      date = Date.today
      @ev.age_calculation_base_date = date
      expect(@ev.effective_age_calculation_base_date).to eq(date)
    end

    it "uses the start_date if age_calculation_base_date is nil" do
      date = Date.today
      @ev.start_date = date
      @ev.age_calculation_base_date = nil
      expect(@ev.effective_age_calculation_base_date).to eq(date)
    end
  end

  it "defaults test_mode to false" do
    ev = EventConfiguration.new
    expect(ev.test_mode).to eq(false)
  end

  it "should be open if no periods are defined" do
    @ev.save
    expect(EventConfiguration.closed?).to eq(false)
  end

  it "should be closed if it is under construction" do
    @ev.under_construction = true
    expect(@ev.registration_closed?).to be_truthy
  end

  it "should NOT have standard_skill_closed by default " do
    travel_to(Date.new(2013, 1, 1)) do
      expect(EventConfiguration.singleton.standard_skill_closed?).to eq(false)
    end
  end

  describe "with the standard_skill_closed_date defined" do
    it "should be closed on the 6th" do
      @ev.save!
      travel_to(Date.new(2013, 5, 4)) do
        expect(EventConfiguration.singleton.standard_skill_closed?).to eq(false)
      end
      travel_to(Date.new(2013, 5, 5)) do
        expect(EventConfiguration.singleton.standard_skill_closed?).to eq(false)
      end
      travel_to(Date.new(2013, 5, 6)) do
        expect(EventConfiguration.singleton.standard_skill_closed?).to eq(true)
      end
    end
  end

  describe "with a registration cost" do
    before(:each) do
      FactoryGirl.create(:event_configuration)
      @rp = FactoryGirl.create(:registration_cost, start_date: Date.new(2012, 11, 03), end_date: Date.new(2012, 11, 07))
    end
    it "should be open on the last day of registration" do
      travel_to(Date.new(2012, 11, 07)) do
        expect(EventConfiguration.closed?).to eq(false)
      end
    end
    it "should be open as long as the registration_period is current" do
      d = Date.new(2012, 11, 07)
      travel_to(d) do
        expect(@rp.current_period?(d)).to eq(true)
        expect(EventConfiguration.closed?).to eq(false)
      end

      e = Date.new(2012, 11, 8)
      travel_to(e) do
        expect(@rp.current_period?(e)).to eq(true)
        expect(EventConfiguration.closed?).to eq(false)
      end

      f = Date.new(2012, 11, 9)
      travel_to(f) do
        expect(@rp.current_period?(f)).to eq(false)
        expect(EventConfiguration.closed?).to eq(true)
      end
    end
  end

  it "returns the live paypal url when paypal mode is enabled" do
    @ev.update_attribute(:paypal_mode, "enabled")
    expect(EventConfiguration.paypal_base_url).to eq("https://www.paypal.com")
  end
  it "returns the test paypal url when paypal mode is TEST" do
    @ev.update_attribute(:paypal_mode, "test")
    expect(EventConfiguration.paypal_base_url).to eq("https://www.sandbox.paypal.com")
  end

  describe "when doing partial_model validations" do
    it "allows short_name nil when not validated" do
      @ec = FactoryGirl.build :event_configuration
      @ec.validations_applied = 0
      @ec.short_name = nil
      expect(@ec).to be_valid

      @ec.apply_validation(:name_logo)
      expect(@ec).to be_invalid
    end
  end
end
