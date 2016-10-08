# == Schema Information
#
# Table name: registrants
#
#  id                       :integer          not null, primary key
#  first_name               :string(255)
#  middle_initial           :string(255)
#  last_name                :string(255)
#  birthday                 :date
#  gender                   :string(255)
#  created_at               :datetime
#  updated_at               :datetime
#  user_id                  :integer
#  deleted                  :boolean          default(FALSE), not null
#  bib_number               :integer
#  wheel_size_id            :integer
#  age                      :integer
#  ineligible               :boolean          default(FALSE), not null
#  volunteer                :boolean          default(FALSE), not null
#  online_waiver_signature  :string(255)
#  access_code              :string(255)
#  sorted_last_name         :string(255)
#  status                   :string(255)      default("active"), not null
#  registrant_type          :string(255)      default("competitor")
#  rules_accepted           :boolean          default(FALSE), not null
#  online_waiver_acceptance :boolean          default(FALSE), not null
#
# Indexes
#
#  index_registrants_deleted             (deleted)
#  index_registrants_on_registrant_type  (registrant_type)
#  index_registrants_on_user_id          (user_id)
#

require 'spec_helper'

describe RegistrantsController do
  let!(:event_configuration) { FactoryGirl.create(:event_configuration, event_sign_up_closed_date: Date.tomorrow) }
  before(:each) do
    @user = FactoryGirl.create(:user)
    sign_in @user
  end

  # This should return the minimal set of attributes required to create a valid
  # Registrant. As you add validations to Registrant, be sure to
  # update the return value of this method accordingly.
  def valid_attributes
    {
      first_name: "Robin",
      last_name: "Dunlop",
      gender: "Male",
      user_id: @user.id,
      birthday: Date.new(1982, 1, 19),
      contact_detail_attributes: {
        address: "123 Fake Street",
        city: "Madison",
        state_code: "WI",
        country_residence: "US",
        zip: "12345",
        club: "TCUC",
        club_contact: "Connie",
        organization_member_number: "12345",
        volunteer: false,
        emergency_name: "Jane",
        emergency_relationship: "Sig. Oth.",
        emergency_attending: true,
        emergency_primary_phone: "306-222-1212",
        emergency_other_phone: "911",
        responsible_adult_name: "Andy",
        responsible_adult_phone: "312-555-5555"
      }
    }
  end

  describe "GET index" do
    context "with a registrant" do
      let!(:registrant) { FactoryGirl.create(:competitor, user: @user, first_name: "Robin", last_name: "Dunlop") }

      it "assigns all registrants as @registrants" do
        FactoryGirl.create(:registrant) # other user's registrant
        get :index, params: { user_id: @user.id }

        assert_select "legend", text: "Registrations", count: 1

        assert_select "a", text: "Robin Dunlop".to_s, count: 1
        assert_select "a", text: "Pay Now".to_s, count: 1
      end
    end

    context "without any registrants" do
      it "should not render the registrants list" do
        get :index, params: { user_id: @user.id }

        assert_select "legend", text: "Registrations", count: 0
      end

      it "should not render the amount owing block" do
        get :index, params: { user_id: @user.id }

        assert_select "div", text: /Pay Now/, count: 0
      end
    end

    describe "as the sender of a registration request" do
      describe "when I have been granted additional_access" do
        before(:each) do
          @other_reg = FactoryGirl.create(:competitor)
          FactoryGirl.create(:additional_registrant_access, user: @user, accepted_readonly: true, registrant: @other_reg)
        end
        it "shows the registrant" do
          get :index, params: { user_id: @user.id }
          expect(assigns(:shared_registrants)).to eq([@other_reg])
        end
      end
    end
  end

  describe "get all" do
    it "assigns all registrants as @registrants" do
      registrant = FactoryGirl.create(:competitor, user: @user)
      other_reg = FactoryGirl.create(:registrant)
      get :all
      expect(assigns(:registrants)).to eq([registrant, other_reg])
    end
  end

  describe "GET waiver" do
    let(:registrant) { FactoryGirl.create(:competitor, user: @user) }
    let!(:event_configuration) { FactoryGirl.create(:event_configuration, start_date: Date.new(2013, 7, 21)) }

    it "assigns the requested registrant as @registrant" do
      get :waiver, params: { id: registrant.to_param }
      expect(response).to be_success
      expect(assigns(:registrant)).to eq(registrant)
    end

    it "sets the event-related variables" do
      allow(Date).to receive(:today).and_return(Date.new(2012, 1, 22))
      get :waiver, params: { id: registrant.to_param }

      expect(assigns(:event_name)).to eq(event_configuration.long_name)
      expect(assigns(:event_start_date)).to eq("Jul 21, 2013")

      expect(assigns(:today_date)).to eq("January 22, 2012")
    end

    it "sets the contact details" do
      get :waiver, params: { id: registrant.to_param }

      expect(assigns(:name)).to eq(registrant.to_s)
      expect(assigns(:club)).to eq(registrant.club)
      expect(assigns(:age)).to eq(registrant.age)
      expect(assigns(:country)).to eq("US")
    end

    it "sets the emergency-variables" do
      get :waiver, id: registrant.to_param

      expect(assigns(:emergency_name)).to eq(registrant.contact_detail.emergency_name)
      expect(assigns(:emergency_primary_phone)).to eq(registrant.contact_detail.emergency_primary_phone)
      expect(assigns(:emergency_other_phone)).to eq(registrant.contact_detail.emergency_other_phone)
    end
  end

  describe "GET show" do
    it "assigns the requested registrant as @registrant" do
      registrant = FactoryGirl.create(:competitor, user: @user)
      get :show, params: { id: registrant.to_param }
      expect(assigns(:registrant)).to eq(registrant)
    end

    it "cannot read another user's registrant" do
      registrant = FactoryGirl.create(:competitor, user: @user)
      sign_in FactoryGirl.create(:user)
      get :show, params: { id: registrant.to_param }
      expect(response).to redirect_to(root_path)
    end
    describe "as an admin" do
      before(:each) do
        sign_in FactoryGirl.create(:convention_admin_user)
      end
      it "Can read other users registrant" do
        registrant = FactoryGirl.create(:competitor, user: @user)
        get :show, params: { id: registrant.to_param }
        expect(assigns(:registrant)).to eq(registrant)
      end
    end

    context "as a usa-enabled membership system" do
      let!(:event_configuration) { FactoryGirl.create(:event_configuration, :with_usa) }

      it "can show the page" do
        registrant = FactoryGirl.create(:competitor, user: @user)
        get :show, params: { id: registrant.to_param }
        expect(assigns(:registrant)).to eq(registrant)
      end
    end
  end

  describe "DELETE destroy" do
    before(:each) do
      sign_in @user
    end
    it "destroys the requested registrant" do
      registrant = FactoryGirl.create(:competitor, user: @user)
      expect do
        delete :destroy, params: { id: registrant.to_param }
      end.to change(Registrant.active, :count).by(-1)
    end

    it "sets the registrant as 'deleted'" do
      registrant = FactoryGirl.create(:competitor, user: @user)
      delete :destroy, params: { id: registrant.to_param }
      registrant.reload
      expect(registrant.deleted).to eq(true)
    end

    it "redirects to the registrants list" do
      registrant = FactoryGirl.create(:competitor, user: @user)
      delete :destroy, params: { id: registrant.to_param }
      expect(response).to redirect_to(root_path)
    end

    describe "as normal user" do
      before(:each) do
        sign_in @user
      end
      it "cannot destroy another user's registrant" do
        registrant = FactoryGirl.create(:competitor)
        delete :destroy, params: { id: registrant.to_param }
        expect(response).to redirect_to(root_path)
      end
    end
  end
end
