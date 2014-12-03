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
        state: "WI",
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
      assigns(:my_registrants).should eq([registrant])
      assigns(:shared_registrants).should == []
    end

    describe "as the sender of a registration request" do
      describe "when I have been granted additional_access" do
        before(:each) do
          @other_reg = FactoryGirl.create(:competitor)
          FactoryGirl.create(:additional_registrant_access, :user => @user, :accepted_readonly => true, :registrant => @other_reg)
        end
        it "shows the registrant" do
          get :index, {:user_id => @user.id}
          assigns(:shared_registrants).should == [@other_reg]
        end
      end
    end
  end

  describe "get all" do
    it "assigns all registrants as @registrants" do
      registrant = FactoryGirl.create(:competitor, :user => @user)
      other_reg = FactoryGirl.create(:registrant)
      get :all, {}
      assigns(:registrants).should eq([registrant, other_reg])
    end
  end

  describe "GET waiver" do
    it "assigns the requested registrant as @registrant" do
      registrant = FactoryGirl.create(:competitor, :user => @user)
      get :waiver, {:id => registrant.to_param}
      response.should be_success
      assigns(:registrant).should eq(registrant)
    end

    it "sets the event-related variables" do
      registrant = FactoryGirl.create(:competitor, :user => @user)
      c = FactoryGirl.create(:event_configuration, :start_date => Date.new(2013, 07, 21))
      Date.stub(:today).and_return(Date.new(2012, 01, 22))
      get :waiver, {:id => registrant.to_param}

      assigns(:event_name).should == c.long_name
      assigns(:event_start_date).should == "Jul 21, 2013"

      assigns(:today_date).should == "January 22, 2012"
    end

    it "sets the contact details" do
      registrant = FactoryGirl.create(:competitor, :user => @user)
      c = FactoryGirl.create(:event_configuration, :start_date => Date.new(2013, 07, 21))
      get :waiver, {:id => registrant.to_param}

      assigns(:name).should == registrant.to_s
      assigns(:club).should == registrant.club
      assigns(:age).should == registrant.age
      assigns(:country).should == "United States"
    end
    it "sets the emergency-variables" do
      registrant = FactoryGirl.create(:competitor, :user => @user)
      c = FactoryGirl.create(:event_configuration, :start_date => Date.new(2013, 07, 21))
      get :waiver, {:id => registrant.to_param}

      assigns(:emergency_name).should == registrant.contact_detail.emergency_name
      assigns(:emergency_primary_phone).should == registrant.contact_detail.emergency_primary_phone
      assigns(:emergency_other_phone).should == registrant.contact_detail.emergency_other_phone
    end
  end

  describe "GET show" do
    it "assigns the requested registrant as @registrant" do
      registrant = FactoryGirl.create(:competitor, :user => @user)
      get :show, {:id => registrant.to_param}
      assigns(:registrant).should eq(registrant)
    end

    it "cannot read another user's registrant" do
      registrant = FactoryGirl.create(:competitor, :user => @user)
      sign_in FactoryGirl.create(:user)
      get :show, {:id => registrant.to_param}
      response.should redirect_to(root_path)
    end
    describe "as an admin" do
      before(:each) do
        sign_in FactoryGirl.create(:admin_user)
      end
      it "Can read other users registrant" do
        registrant = FactoryGirl.create(:competitor, :user => @user)
        get :show, {:id => registrant.to_param}
        assigns(:registrant).should eq(registrant)
      end
    end
  end

  describe "GET new" do
    it "assigns a new competitor as @registrant" do
      get :new, {registrant_type: 'competitor'}
      assigns(:registrant).should be_a_new(Registrant)
      assigns(:registrant).competitor.should == true
    end
    it "returns a list of all of the events" do
      @category1 = FactoryGirl.create(:category, :position => 1)
      @category3 = FactoryGirl.create(:category, :position => 3)
      @category2 = FactoryGirl.create(:category, :position => 2)

      get 'new', {registrant_type: 'competitor'}
      assigns(:categories).should == [@category1, @category2, @category3]
    end
    it "sets other_registrant as nil" do
      get :new
      assigns(:other_registrant).should == nil
    end

    describe "when another registrant already exists" do
      before(:each) do
        @other_reg = FactoryGirl.create(:registrant, :user => @user)
      end
      it "should set it as other_reg" do
        get :new
        assigns(:other_registrant).should == @other_reg
      end
    end
    describe "when the system is 'closed'" do
      before(:each) do
        FactoryGirl.create(:registration_period, :start_date => Date.new(2010, 01, 01), :end_date => Date.new(2010, 02, 02))
      end
      it "should not succeed" do
        EventConfiguration.closed?.should == true
        get :new
        response.should_not be_success
      end
    end
  end

  describe "GET new (noncompetitor)" do
    it "assigns a new noncompetitor as @registrant" do
      get :new, {registrant_type: 'noncompetitor'}
      assigns(:registrant).should be_a_new(Registrant)
      assigns(:registrant).competitor.should == false
      assigns(:categories).should == nil
    end
  end

  describe "GET edit" do
    it "assigns the requested registrant as @registrant" do
      registrant = FactoryGirl.create(:competitor, :user => @user)
      get :edit, {:id => registrant.to_param}
      assigns(:registrant).should eq(registrant)
    end
    it "should not load categories for a noncompetitor" do
      category1 = FactoryGirl.create(:category, :position => 1)
      registrant = FactoryGirl.create(:noncompetitor, :user => @user)
      get :edit, {:id => registrant.to_param}
      response.should be_success
      assigns(:categories).should == nil
    end
  end

  describe "POST create" do
    describe "with valid params" do
      before(:each) do
        @ws20 = FactoryGirl.create(:wheel_size_20)
        @ws24 = FactoryGirl.create(:wheel_size_24)
        @comp_attributes = valid_attributes.merge({registrant_type: 'competitor'})
      end
      it "creates a new Registrant" do
        expect {
          post :create, {:registrant => @comp_attributes}
        }.to change(Registrant, :count).by(1)
      end

      it "assigns the registrant to the current user" do
        expect {
          post :create, {:registrant => valid_attributes.merge(
            registrant_type: 'competitor')
          }
        }.to change(Registrant, :count).by(1)
        Registrant.last.user.should == @user
        Registrant.last.contact_detail.should_not be_nil
      end

      it "sets the registrant as a competitor" do
        post :create, {:registrant => @comp_attributes}
        Registrant.last.competitor.should == true
      end

      it "assigns a newly created registrant as @registrant" do
        post :create, {:registrant => @comp_attributes}
        assigns(:registrant).should be_a(Registrant)
        assigns(:registrant).should be_persisted
      end

      it "redirects to the created registrant" do
        post :create, {:registrant => @comp_attributes}
        response.should redirect_to(registrant_registrant_expense_items_path(Registrant.last))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved registrant as @registrant" do
        # Trigger the behavior that occurs when invalid params are submitted
        Registrant.any_instance.stub(:save).and_return(false)
        post :create, {:registrant => {registrant_type: 'competitor'}}
        assigns(:registrant).should be_a_new(Registrant)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        Registrant.any_instance.stub(:save).and_return(false)
        post :create, {:registrant => {registrant_type: 'competitor'}}
        response.should render_template("new")
      end
      it "has categories" do
        # Trigger the behavior that occurs when invalid params are submitted
        category1 = FactoryGirl.create(:category, :position => 1)
        Registrant.any_instance.stub(:save).and_return(false)
        post :create, {:registrant => {registrant_type: 'competitor'}}
        assigns(:categories).should == [category1]
      end
      it "should not load categories for a noncompetitor" do
        category1 = FactoryGirl.create(:category, :position => 1)
        Registrant.any_instance.stub(:save).and_return(false)
        post :create, {:registrant => {registrant_type: 'noncompetitor'}}
        assigns(:categories).should == nil
      end
    end
    describe "When creating nested registrant choices" do
      before(:each) do
        @reg = FactoryGirl.create(:registrant, :user => @user)
        @ev = FactoryGirl.create(:event)
        @ec = FactoryGirl.create(:event_choice, :event => @ev)
        @attributes = valid_attributes.merge({
                                               registrant_type: 'competitor',
                                               :registrant_event_sign_ups_attributes => [
                                                 { :signed_up => "1",
                                                   :event_category_id => @ev.event_categories.first.id,
                                                   :event_id => @ev.id
                                                 }
                                               ],
                                               :registrant_choices_attributes => [
                                                 { :event_choice_id => @ec.id,
                                                   :value => "1"
                                                 }
                                               ]
                                             })
      end

      it "creates a corresponding event_choice when checkbox is selected" do
        expect {
          post 'create', {:id => @reg, :registrant => @attributes}
        }.to change(RegistrantChoice, :count).by(1)
      end

      it "doesn't create a new entry if one already exists" do
        RegistrantChoice.count.should == 0
        put :update, {:id => @reg.to_param, :registrant => @attributes}
        RegistrantChoice.count.should == 1
      end
      it "can update an existing registrant_choice" do
        put :update, {:id => @reg.to_param, :registrant => @attributes}
        @attributes[:registrant_event_sign_ups_attributes][0][:id] = RegistrantEventSignUp.first.id
        @attributes[:registrant_choices_attributes][0][:id] = RegistrantChoice.first.id
        put :update, {:id => @reg.to_param, :registrant => @attributes}
        response.should redirect_to(registrant_registrant_expense_items_path(@reg))
      end
    end

    describe "when creating registrant_event_sign_ups" do
      before(:each) do
        @reg = FactoryGirl.create(:registrant, :user => @user)
        @ecat = FactoryGirl.create(:event).event_categories.first
        @attributes = valid_attributes.merge({
                                               registrant_type: 'competitor',
                                               :registrant_event_sign_ups_attributes => [
                                                 { :event_category_id => @ecat.id,
                                                   :event_id => @ecat.event.id,
                                                   :signed_up => "1"
                                             }
                                               ]
                                             })
        @new_attributes = valid_attributes.merge({
                                                   registrant_type: 'competitor',
                                                   :registrant_event_sign_ups_attributes => [
                                                     { :event_category_id => @ecat.id,
                                                       :event_id => @ecat.event.id,
                                                       :signed_up => "0"
                                                 }
                                                   ]
                                                 })
      end

      it "creates corresponding registrant_event_sign_ups" do
        expect {
          post 'create', {:id => @reg, :registrant => @attributes}
        }.to change(RegistrantEventSignUp, :count).by(1)
      end

      it "can update the registrant_event_sign_up" do
        put :update, {:id => @reg.to_param, :registrant => @attributes}
        response.should redirect_to(registrant_registrant_expense_items_path(@reg))
        @new_attributes[:registrant_event_sign_ups_attributes][0][:id] = RegistrantEventSignUp.first.id
        expect {
          put :update, {:id => @reg.to_param, :registrant => @new_attributes}
        }.to change(RegistrantEventSignUp, :count).by(0)
        response.should redirect_to(registrant_registrant_expense_items_path(@reg))
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested registrant" do
        registrant = FactoryGirl.create(:competitor, :user => @user)
        # Assuming there are no other registrants in the database, this
        # specifies that the Registrant created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        Registrant.any_instance.should_receive(:update_attributes).with({})
        put :update, {:id => registrant.to_param, :registrant => {'these' => 'params'}}
      end

      it "assigns the requested registrant as @registrant" do
        registrant = FactoryGirl.create(:competitor, :user => @user)
        put :update, {:id => registrant.to_param, :registrant => valid_attributes}
        assigns(:registrant).should eq(registrant)
      end

      it "cannot change the competitor to a non-competitor" do
        registrant = FactoryGirl.create(:competitor, :user => @user)
        put :update, {:id => registrant.to_param, :registrant => valid_attributes.merge({registrant_type: 'noncompetitor'})}
        assigns(:registrant).should eq(registrant)
        assigns(:registrant).competitor.should == true
      end

      it "redirects competitors to the items" do
        registrant = FactoryGirl.create(:competitor, :user => @user)
        put :update, {:id => registrant.to_param, :registrant => valid_attributes}
        response.should redirect_to(registrant_registrant_expense_items_path(Registrant.last))
      end
      it "redirects noncompetitors to the items" do
        registrant = FactoryGirl.create(:noncompetitor, :user => @user)
        put :update, {:id => registrant.to_param, :registrant => valid_attributes}
        response.should redirect_to(registrant_registrant_expense_items_path(Registrant.last))
      end
    end

    describe "with invalid params" do
      let(:registrant) { FactoryGirl.create(:competitor, user: @user) }
      let(:do_action) {
        put :update, {:id => registrant.to_param, :registrant => {registrant_type: 'competitor'}}
      }
      it "assigns the registrant as @registrant" do
        # Trigger the behavior that occurs when invalid params are submitted
        Registrant.any_instance.stub(:save).and_return(false)
        do_action
        assigns(:registrant).should eq(registrant)
      end
      it "loads the categories" do
        category1 = FactoryGirl.create(:category, :position => 1)
        Registrant.any_instance.stub(:save).and_return(false)
        do_action
        assigns(:categories).should == [category1]
      end

      it "re-renders the 'edit' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        Registrant.any_instance.stub(:save).and_return(false)
        do_action
        response.should render_template("edit")
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
      registrant.deleted.should == true
    end

    it "redirects to the registrants list" do
      registrant = FactoryGirl.create(:competitor, :user => @user)
      delete :destroy, {:id => registrant.to_param}
      response.should redirect_to(manage_all_registrants_path)
    end

    describe "as normal user" do
      before(:each) do
        sign_in @user
      end
      it "cannot destroy another user's registrant" do
        registrant = FactoryGirl.create(:competitor)
        delete :destroy, {:id => registrant.to_param}
        response.should redirect_to(root_path)
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
        assigns(:registrants).should =~[registrant, other_reg]
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
        registrant.deleted.should == false
      end

      it "redirects to the index" do
        registrant = FactoryGirl.create(:competitor, :deleted => true)
        post :undelete, {:id => registrant.to_param }
        response.should redirect_to(manage_all_registrants_path)
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
          registrant.deleted.should == true
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
        @reg.owing_expense_items.count.should == 1
        @reg.owing_expense_items.first.should == @rp2.competitor_expense_item
      end

      it "can be changed to a different reg period" do
        put :update_reg_fee, {:id => @reg.to_param, :registration_period_id => @rp1.id }
        response.should redirect_to reg_fee_registrant_path(@reg)
        @reg.reload
        @reg.owing_expense_items.count.should == 1
        @reg.owing_expense_items.first.should == @rp1.competitor_expense_item
        @reg.registrant_expense_items.first.locked.should == true
      end
      it "cannot be updated if the registrant is already paid" do
        payment = FactoryGirl.create(:payment)
        pd = FactoryGirl.create(:payment_detail, :registrant => @reg, :expense_item => @reg.registrant_expense_items.first.expense_item, :payment => payment)
        payment.completed = true
        payment.save
        @reg.reload
        put :update_reg_fee, {:id => @reg.to_param, :registration_period_id => @rp1.id }
        response.should render_template("reg_fee")
      end
    end
  end
end
