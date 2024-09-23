# == Schema Information
#
# Table name: event_configurations
#
#  id                                            :integer          not null, primary key
#  event_url                                     :string
#  start_date                                    :date
#  contact_email                                 :string
#  artistic_closed_date                          :date
#  standard_skill_closed_date                    :date
#  event_sign_up_closed_date                     :date
#  created_at                                    :datetime
#  updated_at                                    :datetime
#  test_mode                                     :boolean          default(FALSE), not null
#  comp_noncomp_url                              :string
#  standard_skill                                :boolean          default(FALSE), not null
#  usa                                           :boolean          default(FALSE), not null
#  iuf                                           :boolean          default(FALSE), not null
#  currency_code                                 :string
#  rulebook_url                                  :string
#  style_name                                    :string
#  custom_waiver_text                            :text
#  music_submission_end_date                     :date
#  artistic_score_elimination_mode_naucc         :boolean          default(FALSE), not null
#  logo_file                                     :string
#  max_award_place                               :integer          default(5)
#  display_confirmed_events                      :boolean          default(FALSE), not null
#  spectators                                    :boolean          default(FALSE), not null
#  paypal_account                                :string
#  waiver                                        :string           default("none")
#  validations_applied                           :integer
#  italian_requirements                          :boolean          default(FALSE), not null
#  rules_file_name                               :string
#  accept_rules                                  :boolean          default(FALSE), not null
#  payment_mode                                  :string           default("disabled")
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
#  max_registrants                               :integer          default(0), not null
#  representation_type                           :string           default("country"), not null
#  waiver_file_name                              :string
#  lodging_end_date                              :datetime
#  time_zone                                     :string           default("Central Time (US & Canada)")
#  stripe_public_key                             :string
#  stripe_secret_key                             :string
#  require_medical_certificate                   :boolean          default(FALSE), not null
#  medical_certificate_info_page_id              :integer
#  volunteer_option_page_id                      :integer
#  add_expenses_end_date                         :datetime
#

require 'spec_helper'

describe EventConfiguration do
  # so that I can test print_item_cost_currency
  include ApplicationHelper

  before do
    @ev = described_class.singleton
    @ev.assign_attributes(FactoryBot.attributes_for(:event_configuration, standard_skill_closed_date: Date.new(2013, 5, 5)))
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

  it { expect(@ev).to validate_inclusion_of(:organization_membership_type).in_array(described_class.organization_membership_types) }
  it { is_expected.to allow_value(nil).for(:organization_membership_type) }
  it { is_expected.to allow_value("").for(:organization_membership_type) }

  context "when in EUR format" do
    before do
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
    expect(described_class.style_names.count).to be > 0
  end

  it "style_name must be a valid_style_name" do
    @ev.style_name = "fake"
    @ev.apply_validation(:base_settings)
    expect(@ev.valid?).to eq(false)

    @ev.style_name = described_class.style_names.first[1]
    expect(@ev.valid?).to eq(true)
  end

  it "has a style_name even without having any entries" do
    expect(described_class.new.style_name).to eq("base_green_blue")
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
    @ev.comp_noncomp_page_id = FactoryBot.create(:page).id
    expect(@ev).to be_invalid
  end

  it "Can have a info page" do
    @ev.comp_noncomp_page_id = FactoryBot.create(:page).id
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
      date = Date.current
      @ev.age_calculation_base_date = date
      expect(@ev.effective_age_calculation_base_date).to eq(date)
    end

    it "uses the start_date if age_calculation_base_date is nil" do
      date = Date.current
      @ev.start_date = date
      @ev.age_calculation_base_date = nil
      expect(@ev.effective_age_calculation_base_date).to eq(date)
    end
  end

  it "defaults test_mode to false" do
    ev = described_class.new
    expect(ev.test_mode).to eq(false)
  end

  it "is open if no periods are defined" do
    @ev.update_attribute(:event_sign_up_closed_date, nil)
    @ev.save
    expect(described_class.singleton.competitor_registration_closed?).to eq(false)
    expect(described_class.singleton.noncompetitor_registration_closed?).to eq(false)
  end

  it "is closed if the event_closed_date is defined, and in the past" do
    ev = described_class.new(under_construction: false)
    ev.event_sign_up_closed_date = Date.new(2013, 5, 1)
    travel_to(Date.new(2013, 5, 4)) do
      expect(ev).to be_competitor_registration_closed
      expect(ev).to be_noncompetitor_registration_closed
    end

    travel_to(Date.new(2013, 5, 1)) do
      expect(ev).not_to be_competitor_registration_closed
      expect(ev).not_to be_noncompetitor_registration_closed
    end
  end

  it "is closed if it is under construction" do
    @ev.under_construction = true
    expect(@ev).to be_competitor_registration_closed
    expect(@ev).to be_noncompetitor_registration_closed
  end

  describe "#new_registration_closed_for_limit?" do
    let(:ev) { described_class.new(under_construction: false) }

    before do
      ev.event_sign_up_closed_date = Date.new(2013, 5, 1)
    end

    it "is closed if registration_closed?" do
      travel_to(Date.new(2013, 5, 4)) do
        expect(ev).to be_competitor_registration_closed
        expect(ev).to be_new_registration_closed_for_limit
      end
    end

    it "is closed if the number of registrants is >= the max_limit" do
      FactoryBot.create(:competitor)

      travel_to(Date.new(2013, 5, 1)) do
        expect(ev).not_to be_competitor_registration_closed
        ev.max_registrants = 1
        expect(ev).to be_new_registration_closed_for_limit

        FactoryBot.create(:competitor)
        expect(ev).to be_new_registration_closed_for_limit
      end
    end
  end

  it "does not have standard_skill_closed by default " do
    travel_to(Date.new(2013, 1, 1)) do
      expect(described_class.singleton.standard_skill_closed?).to eq(false)
    end
  end

  describe "with the standard_skill_closed_date defined" do
    it "is closed on the 6th" do
      @ev.save!
      travel_to(Date.new(2013, 5, 4)) do
        expect(described_class.singleton.standard_skill_closed?).to eq(false)
      end
      travel_to(Date.new(2013, 5, 5)) do
        expect(described_class.singleton.standard_skill_closed?).to eq(false)
      end
      travel_to(Date.new(2013, 5, 6)) do
        expect(described_class.singleton.standard_skill_closed?).to eq(true)
      end
    end
  end

  describe "with a registration cost" do
    before do
      FactoryBot.create(:event_configuration)
      @rp = FactoryBot.create(:registration_cost, start_date: Date.new(2012, 11, 3), end_date: Date.new(2012, 11, 7))
    end

    it "is open on the last day of registration" do
      travel_to(Date.new(2012, 11, 7)) do
        expect(described_class.singleton.competitor_registration_closed?).to eq(false)
      end
    end

    it "is open as long as the registration_period is current" do
      d = Date.new(2012, 11, 7)
      travel_to(d) do
        expect(@rp.current_period?(d)).to eq(true)
        expect(described_class.singleton.competitor_registration_closed?).to eq(false)
      end

      e = Date.new(2012, 11, 8)
      travel_to(e) do
        expect(@rp.current_period?(e)).to eq(true)
        expect(described_class.singleton.competitor_registration_closed?).to eq(false)
      end

      f = Date.new(2012, 11, 9)
      travel_to(f) do
        expect(@rp.current_period?(f)).to eq(false)
        expect(described_class.singleton.competitor_registration_closed?).to eq(true)
      end
    end
  end

  it "returns the live paypal url when paypal mode is enabled" do
    @ev.update_attribute(:payment_mode, "enabled")
    expect(described_class.paypal_base_url).to eq("https://www.paypal.com")
  end

  it "returns the test paypal url when paypal mode is TEST" do
    @ev.update_attribute(:payment_mode, "test")
    expect(described_class.paypal_base_url).to eq("https://www.sandbox.paypal.com")
  end

  describe "when doing partial_model validations" do
    it "allows short_name nil when not validated" do
      @ec = FactoryBot.build :event_configuration
      @ec.validations_applied = 0
      @ec.short_name = nil
      expect(@ec).to be_valid

      @ec.apply_validation(:name_logo)
      expect(@ec).to be_invalid
    end
  end
end
