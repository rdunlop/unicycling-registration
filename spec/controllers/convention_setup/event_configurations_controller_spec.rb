# == Schema Information
#
# Table name: event_configurations
#
#  id                                    :integer          not null, primary key
#  event_url                             :string(255)
#  start_date                            :date
#  contact_email                         :string(255)
#  artistic_closed_date                  :date
#  standard_skill_closed_date            :date
#  event_sign_up_closed_date             :date
#  created_at                            :datetime
#  updated_at                            :datetime
#  test_mode                             :boolean          default(FALSE), not null
#  comp_noncomp_url                      :string(255)
#  standard_skill                        :boolean          default(FALSE), not null
#  usa                                   :boolean          default(FALSE), not null
#  iuf                                   :boolean          default(FALSE), not null
#  currency_code                         :string(255)
#  rulebook_url                          :string(255)
#  style_name                            :string(255)
#  custom_waiver_text                    :text
#  music_submission_end_date             :date
#  artistic_score_elimination_mode_naucc :boolean          default(TRUE), not null
#  usa_individual_expense_item_id        :integer
#  usa_family_expense_item_id            :integer
#  logo_file                             :string(255)
#  max_award_place                       :integer          default(5)
#  display_confirmed_events              :boolean          default(FALSE), not null
#  spectators                            :boolean          default(FALSE), not null
#  usa_membership_config                 :boolean          default(FALSE), not null
#  paypal_account                        :string(255)
#  waiver                                :string(255)      default("none")
#  validations_applied                   :integer
#  italian_requirements                  :boolean          default(FALSE), not null
#  rules_file_name                       :string(255)
#  accept_rules                          :boolean          default(FALSE), not null
#  paypal_mode                           :string(255)      default("disabled")
#  offline_payment                       :boolean          default(FALSE), not null
#  enabled_locales                       :string           default("en,fr"), not null
#  comp_noncomp_page_id                  :integer
#  under_construction                    :boolean          default(TRUE), not null
#

require 'spec_helper'

describe ConventionSetup::EventConfigurationsController do
  before(:each) do
    @user = FactoryGirl.create(:super_admin_user)
    sign_in @user
  end

  ConventionSetup::EventConfigurationsController::EVENT_CONFIG_PAGES.each do |page|
    it "can render the #{page} page" do
      get page
      expect(response).to be_success
    end
  end

  # This should return the minimal set of attributes required to create a valid
  # EventConfiguration. As you add validations to EventConfiguration, be sure to
  # update the return value of this method accordingly.
  def valid_attributes
    {
      test_mode: true,
      standard_skill_closed_date: Date.tomorrow,
      translations_attributes: {
        "1" => {
          locale: "en",
          short_name: "something short",
          long_name: "Something Long"
        }
      },
      style_name: "base_blue_pink"
    }
  end

  describe "as a logged in user" do
    let(:event_configuration) { EventConfiguration.singleton }

    before do
      @user = FactoryGirl.create(:user)
      sign_in @user
      event_configuration.update(valid_attributes)
    end

    it "Cannot edit configuration" do
      get :advanced_settings, params: { id: event_configuration.to_param }
      expect(response).to redirect_to(root_path)
    end

    describe "POST 'test_mode_role'" do
      before :each do
        request.env["HTTP_REFERER"] = root_url
      end
      it "redirects to root" do
        post :test_mode_role, params: { role: "normal_user" }
        expect(response).to redirect_to(root_path)
      end
      it "changes my user to convention_admin" do
        post :test_mode_role, params: { role: "convention_admin" }
        @user.reload
        expect(@user.has_role?(:convention_admin)).to eq(true)
      end
      it "cannot change if config test_mode is disabled" do
        event_configuration.update_attribute(:test_mode, false)
        post :test_mode_role, params: { role: "convention_admin" }
        @user.reload
        expect(@user.has_role?(:convention_admin)).to eq(false)
      end
    end
  end
end
