# == Schema Information
#
# Table name: event_configurations
#
#  id                                    :integer          not null, primary key
#  short_name                            :string(255)
#  long_name                             :string(255)
#  location                              :string(255)
#  dates_description                     :string(255)
#  event_url                             :string(255)
#  start_date                            :date
#  contact_email                         :string(255)
#  artistic_closed_date                  :date
#  standard_skill_closed_date            :date
#  event_sign_up_closed_date             :date
#  created_at                            :datetime
#  updated_at                            :datetime
#  test_mode                             :boolean
#  waiver_url                            :string(255)
#  comp_noncomp_url                      :string(255)
#  standard_skill                        :boolean          default(FALSE)
#  usa                                   :boolean          default(FALSE)
#  iuf                                   :boolean          default(FALSE)
#  currency_code                         :string(255)
#  currency                              :text
#  rulebook_url                          :string(255)
#  style_name                            :string(255)
#  custom_waiver_text                    :text
#  music_submission_end_date             :date
#  artistic_score_elimination_mode_naucc :boolean          default(TRUE)
#  usa_individual_expense_item_id        :integer
#  usa_family_expense_item_id            :integer
#  logo_file                             :string(255)
#  max_award_place                       :integer          default(5)
#  display_confirmed_events              :boolean          default(FALSE)
#  spectators                            :boolean          default(FALSE)
#  usa_membership_config                 :boolean          default(FALSE)
#  paypal_account                        :string(255)
#  paypal_test                           :boolean          default(TRUE), not null
#  waiver                                :string(255)      default("none")
#

require 'spec_helper'

describe EventConfiguration do
  before(:each) do
    @ev = FactoryGirl.build(:event_configuration, :standard_skill_closed_date => Date.new(2013, 5, 5))
  end

  it "is valid from factoryGirl" do
    @ev.valid?.should == true
  end

  it "has a short name" do
    @ev.short_name = nil
    @ev.valid?.should == false
  end

  it "does not allows a blank style_name" do
    @ev.style_name = nil
    @ev.valid?.should == false
  end

  it "has a list of style_names" do
    EventConfiguration.style_names.count.should > 0
  end

  it "style_name must be a valid_style_name" do
    @ev.style_name = "fake"
    @ev.valid?.should == false

    @ev.style_name = EventConfiguration.style_names.first
    @ev.valid?.should == true
  end

  it "has a style_name even without having any entries" do
    EventConfiguration.new.style_name.should == "naucc_2013"
  end

  it "has a long name" do
    @ev.long_name = nil
    @ev.valid?.should == false
  end

  it "event_url can be nil" do
    @ev.event_url = nil
    @ev.valid?.should == true
  end

  it "event_url must be url" do
    @ev.event_url = "hello"
    @ev.valid?.should == false

    @ev.event_url = "http://www.google.com"
    @ev.valid?.should == true
  end

  it "can have a blank comp_noncomp_url" do
    @ev.comp_noncomp_url = ""
    @ev.valid?.should == true
  end

  it "must have a test_mode" do
    @ev.test_mode = nil
    @ev.valid?.should == false
  end

  it "defaults test_mode to true" do
    ev = EventConfiguration.new
    ev.test_mode.should == true
  end

  it "should be open if no periods are defined" do
    EventConfiguration.closed?.should == false
  end

  it "should NOT have standard_skill_closed by default " do
    EventConfiguration.singleton.standard_skill_closed?(Date.new(2013, 1, 1)).should == false
  end

  describe "with the standard_skill_closed_date defined" do
    it "should be closed on the 5th" do
      @ev.save!
      EventConfiguration.singleton.standard_skill_closed?(Date.new(2013, 5, 4)).should == false
      EventConfiguration.singleton.standard_skill_closed?(Date.new(2013, 5, 5)).should == true
      EventConfiguration.singleton.standard_skill_closed?(Date.new(2013, 5, 6)).should == true
    end
  end

  describe "with a registration period" do
    before(:each) do
      @rp = FactoryGirl.create(:registration_period, :start_date => Date.new(2012, 11, 03), :end_date => Date.new(2012, 11, 07))
    end
    it "should be open on the last day of registration" do
      EventConfiguration.closed?(Date.new(2012, 11, 07)).should == false
    end
    it "should be open as long as the registration_period is current" do
      d = Date.new(2012, 11, 07)
      @rp.current_period?(d).should == true
      EventConfiguration.closed?(d).should == false

      e = Date.new(2012, 11, 8)
      @rp.current_period?(e).should == true
      EventConfiguration.closed?(e).should == false

      f = Date.new(2012, 11, 9)
      @rp.current_period?(f).should == false
      EventConfiguration.closed?(f).should == true
    end
  end

  it "returns the live paypal url when TEST is false" do
    @ev.update_attribute(:paypal_test, false)
    EventConfiguration.paypal_base_url.should == "https://www.paypal.com"
  end
  it "returns the test paypal url when TEST is true" do
    @ev.update_attribute(:paypal_test, true)
    EventConfiguration.paypal_base_url.should == "https://www.sandbox.paypal.com"
  end
end
