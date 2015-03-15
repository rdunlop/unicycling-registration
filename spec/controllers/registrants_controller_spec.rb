require 'spec_helper'

describe RegistrantsController do
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
      birthday: Date.new(1982, 01, 19),
      contact_detail_attributes: {
        address: "123 Fake Street",
        city: "Madison",
        state_code: "WI",
        country_residence: "US",
        zip: "12345",
        club: "TCUC",
        club_contact: "Connie",
        usa_member_number: "12345",
        volunteer: false,
        emergency_name: "Caitlin",
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
    it "assigns all registrants as @registrants" do
      registrant = FactoryGirl.create(:competitor, :user => @user)
      other_reg = FactoryGirl.create(:registrant)
      get :index, {:user_id => @user.id}
      expect(assigns(:my_registrants)).to eq([registrant])
      expect(assigns(:shared_registrants)).to eq([])
    end

    describe "as the sender of a registration request" do
      describe "when I have been granted additional_access" do
        before(:each) do
          @other_reg = FactoryGirl.create(:competitor)
          FactoryGirl.create(:additional_registrant_access, :user => @user, :accepted_readonly => true, :registrant => @other_reg)
        end
        it "shows the registrant" do
          get :index, {:user_id => @user.id}
          expect(assigns(:shared_registrants)).to eq([@other_reg])
        end
      end
    end
  end

  describe "get all" do
    it "assigns all registrants as @registrants" do
      registrant = FactoryGirl.create(:competitor, :user => @user)
      other_reg = FactoryGirl.create(:registrant)
      get :all, {}
      expect(assigns(:registrants)).to eq([registrant, other_reg])
    end
  end

  describe "GET waiver" do
    it "assigns the requested registrant as @registrant" do
      registrant = FactoryGirl.create(:competitor, :user => @user)
      get :waiver, {:id => registrant.to_param}
      expect(response).to be_success
      expect(assigns(:registrant)).to eq(registrant)
    end

    it "sets the event-related variables" do
      registrant = FactoryGirl.create(:competitor, :user => @user)
      c = FactoryGirl.create(:event_configuration, :start_date => Date.new(2013, 07, 21))
      allow(Date).to receive(:today).and_return(Date.new(2012, 01, 22))
      get :waiver, {:id => registrant.to_param}

      expect(assigns(:event_name)).to eq(c.long_name)
      expect(assigns(:event_start_date)).to eq("Jul 21, 2013")

      expect(assigns(:today_date)).to eq("January 22, 2012")
    end

    it "sets the contact details" do
      registrant = FactoryGirl.create(:competitor, :user => @user)
      c = FactoryGirl.create(:event_configuration, :start_date => Date.new(2013, 07, 21))
      get :waiver, {:id => registrant.to_param}

      expect(assigns(:name)).to eq(registrant.to_s)
      expect(assigns(:club)).to eq(registrant.club)
      expect(assigns(:age)).to eq(registrant.age)
      expect(assigns(:country)).to eq("US")
    end
    it "sets the emergency-variables" do
      registrant = FactoryGirl.create(:competitor, :user => @user)
      c = FactoryGirl.create(:event_configuration, :start_date => Date.new(2013, 07, 21))
      get :waiver, {:id => registrant.to_param}

      expect(assigns(:emergency_name)).to eq(registrant.contact_detail.emergency_name)
      expect(assigns(:emergency_primary_phone)).to eq(registrant.contact_detail.emergency_primary_phone)
      expect(assigns(:emergency_other_phone)).to eq(registrant.contact_detail.emergency_other_phone)
    end
  end

  describe "GET show" do
    it "assigns the requested registrant as @registrant" do
      registrant = FactoryGirl.create(:competitor, :user => @user)
      get :show, {:id => registrant.to_param}
      expect(assigns(:registrant)).to eq(registrant)
    end

    it "cannot read another user's registrant" do
      registrant = FactoryGirl.create(:competitor, :user => @user)
      sign_in FactoryGirl.create(:user)
      get :show, {:id => registrant.to_param}
      expect(response).to redirect_to(root_path)
    end
    describe "as an admin" do
      before(:each) do
        sign_in FactoryGirl.create(:admin_user)
      end
      it "Can read other users registrant" do
        registrant = FactoryGirl.create(:competitor, :user => @user)
        get :show, {:id => registrant.to_param}
        expect(assigns(:registrant)).to eq(registrant)
      end
    end
  end

  describe "DELETE destroy" do
    before(:each) do
      sign_in @user
    end
    it "destroys the requested registrant" do
      registrant = FactoryGirl.create(:competitor, :user => @user)
      expect {
        delete :destroy, {:id => registrant.to_param}
      }.to change(Registrant.active, :count).by(-1)
    end

    it "sets the registrant as 'deleted'" do
      registrant = FactoryGirl.create(:competitor, :user => @user)
      delete :destroy, {:id => registrant.to_param}
      registrant.reload
      expect(registrant.deleted).to eq(true)
    end

    it "redirects to the registrants list" do
      registrant = FactoryGirl.create(:competitor, :user => @user)
      delete :destroy, {:id => registrant.to_param}
      expect(response).to redirect_to(root_path)
    end

    describe "as normal user" do
      before(:each) do
        sign_in @user
      end
      it "cannot destroy another user's registrant" do
        registrant = FactoryGirl.create(:competitor)
        delete :destroy, {:id => registrant.to_param}
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe "with an admin user" do
    before(:each) do
      sign_out @user
      @admin_user = FactoryGirl.create(:admin_user)
      sign_in @admin_user
    end

    describe "GET manage_all" do
      it "assigns all registrants as @registrants" do
        registrant = FactoryGirl.create(:competitor)
        other_reg = FactoryGirl.create(:registrant)
        get :manage_all, {}
        expect(assigns(:registrants)).to match_array([registrant, other_reg])
      end
    end

    describe "POST undelete" do
      before(:each) do
        FactoryGirl.create(:registration_period)
      end
      it "un-deletes a deleted registration" do
        registrant = FactoryGirl.create(:competitor, :deleted => true)
        post :undelete, {:id => registrant.to_param }
        registrant.reload
        expect(registrant.deleted).to eq(false)
      end

      it "redirects to the root" do
        registrant = FactoryGirl.create(:competitor, :deleted => true)
        post :undelete, {:id => registrant.to_param }
        expect(response).to redirect_to(manage_all_registrants_path)
      end

      describe "as a normal user" do
        before(:each) do
          @user = FactoryGirl.create(:user)
          sign_in @user
        end
        it "Cannot undelete a user" do
          registrant = FactoryGirl.create(:competitor, :deleted => true)
          post :undelete, {:id => registrant.to_param }
          registrant.reload
          expect(registrant.deleted).to eq(true)
        end
      end
    end

    describe "PUT change the reg fee" do
      before(:each) do
        @rp1 = FactoryGirl.create(:registration_period, :start_date => Date.new(2010, 01, 01), :end_date => Date.new(2012, 01, 01))
        @rp2 = FactoryGirl.create(:registration_period, :start_date => Date.new(2012, 01, 02), :end_date => Date.new(2020, 02, 02))
        @reg = FactoryGirl.create(:competitor)
      end

      it "initially has a reg fee from rp2" do
        expect(@reg.owing_expense_items.count).to eq(1)
        expect(@reg.owing_expense_items.first).to eq(@rp2.competitor_expense_item)
      end

      it "can be changed to a different reg period" do
        put :update_reg_fee, {:id => @reg.to_param, :registration_period_id => @rp1.id }
        expect(response).to redirect_to reg_fee_registrant_path(@reg)
        @reg.reload
        expect(@reg.owing_expense_items.count).to eq(1)
        expect(@reg.owing_expense_items.first).to eq(@rp1.competitor_expense_item)
        expect(@reg.registrant_expense_items.first.locked).to eq(true)
      end
      it "cannot be updated if the registrant is already paid" do
        payment = FactoryGirl.create(:payment)
        pd = FactoryGirl.create(:payment_detail, :registrant => @reg, :expense_item => @reg.registrant_expense_items.first.expense_item, :payment => payment)
        payment.completed = true
        payment.save
        @reg.reload
        put :update_reg_fee, {:id => @reg.to_param, :registration_period_id => @rp1.id }
        expect(response).to render_template("reg_fee")
      end
    end
  end
end
