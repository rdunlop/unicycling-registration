require 'spec_helper'

xdescribe Registrants::BuildController do
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

  describe "GET new" do
    it "assigns a new competitor as @registrant" do
      get :new, {registrant_type: 'competitor'}
      expect(assigns(:registrant)).to be_a_new(Registrant)
      expect(assigns(:registrant).competitor).to eq(true)
    end

    describe "when the system is 'closed'" do
      before(:each) do
        FactoryGirl.create(:registration_period, start_date: Date.new(2010, 01, 01), end_date: Date.new(2010, 02, 02))
      end
      it "should not succeed" do
        expect(EventConfiguration.closed?).to eq(true)
        get :new
        expect(response).not_to be_success
      end
    end
  end

  describe "GET edit" do
    it "assigns the requested registrant as @registrant" do
      registrant = FactoryGirl.create(:competitor, user: @user)
      get :edit, {id: registrant.to_param}
      expect(assigns(:registrant)).to eq(registrant)
    end
    it "should not load categories for a noncompetitor" do
      category1 = FactoryGirl.create(:category)
      registrant = FactoryGirl.create(:noncompetitor, user: @user)
      get :edit, {id: registrant.to_param}
      expect(response).to be_success
      expect(assigns(:categories)).to be_nil
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
          post :create, {registrant: @comp_attributes}
        }.to change(Registrant, :count).by(1)
      end

      it "assigns the registrant to the current user" do
        expect {
          post :create, {registrant: valid_attributes.merge(
            registrant_type: 'competitor')
          }
        }.to change(Registrant, :count).by(1)
        expect(Registrant.last.user).to eq(@user)
        expect(Registrant.last.contact_detail).not_to be_nil
      end

      it "sets the registrant as a competitor" do
        post :create, {registrant: @comp_attributes}
        expect(Registrant.last.competitor).to eq(true)
      end

      it "assigns a newly created registrant as @registrant" do
        post :create, {registrant: @comp_attributes}
        expect(assigns(:registrant)).to be_a(Registrant)
        expect(assigns(:registrant)).to be_persisted
      end

      it "redirects to the created registrant" do
        post :create, {registrant: @comp_attributes}
        expect(response).to redirect_to(registrant_registrant_expense_items_path(Registrant.last))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved registrant as @registrant" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Registrant).to receive(:save).and_return(false)
        post :create, {registrant: {registrant_type: 'competitor'}}
        expect(assigns(:registrant)).to be_a_new(Registrant)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Registrant).to receive(:save).and_return(false)
        post :create, {registrant: {registrant_type: 'competitor'}}
        expect(response).to render_template("new")
      end
      it "has categories" do
        # Trigger the behavior that occurs when invalid params are submitted
        category1 = FactoryGirl.create(:category)
        allow_any_instance_of(Registrant).to receive(:save).and_return(false)
        post :create, {registrant: {registrant_type: 'competitor'}}
        expect(assigns(:categories)).to eq([category1])
      end
      it "should not load categories for a noncompetitor" do
        category1 = FactoryGirl.create(:category)
        allow_any_instance_of(Registrant).to receive(:save).and_return(false)
        post :create, {registrant: {registrant_type: 'noncompetitor'}}
        expect(assigns(:categories)).to be_nil
      end
    end
    describe "When creating nested registrant choices" do
      before(:each) do
        @reg = FactoryGirl.create(:registrant, user: @user)
        @ev = FactoryGirl.create(:event)
        @ec = FactoryGirl.create(:event_choice, event: @ev)
        @attributes = valid_attributes.merge({
                                               registrant_type: 'competitor',
                                               registrant_event_sign_ups_attributes: [
                                                 { signed_up: "1",
                                                   event_category_id: @ev.event_categories.first.id,
                                                   event_id: @ev.id
                                                 }
                                               ],
                                               registrant_choices_attributes: [
                                                 { event_choice_id: @ec.id,
                                                   value: "1"
                                                 }
                                               ]
                                             })
      end

      it "creates a corresponding event_choice when checkbox is selected" do
        expect {
          post 'create', {id: @reg, registrant: @attributes}
        }.to change(RegistrantChoice, :count).by(1)
      end

      it "doesn't create a new entry if one already exists" do
        expect(RegistrantChoice.count).to eq(0)
        put :update, {id: @reg.to_param, registrant: @attributes}
        expect(RegistrantChoice.count).to eq(1)
      end
      it "can update an existing registrant_choice" do
        put :update, {id: @reg.to_param, registrant: @attributes}
        @attributes[:registrant_event_sign_ups_attributes][0][:id] = RegistrantEventSignUp.first.id
        @attributes[:registrant_choices_attributes][0][:id] = RegistrantChoice.first.id
        put :update, {id: @reg.to_param, registrant: @attributes}
        expect(response).to redirect_to(registrant_registrant_expense_items_path(@reg))
      end
    end

    describe "when creating registrant_event_sign_ups" do
      before(:each) do
        @reg = FactoryGirl.create(:registrant, user: @user)
        @ecat = FactoryGirl.create(:event).event_categories.first
        @attributes = valid_attributes.merge({
                                               registrant_type: 'competitor',
                                               registrant_event_sign_ups_attributes: [
                                                 { event_category_id: @ecat.id,
                                                   event_id: @ecat.event.id,
                                                   signed_up: "1"
                                             }
                                               ]
                                             })
        @new_attributes = valid_attributes.merge({
                                                   registrant_type: 'competitor',
                                                   registrant_event_sign_ups_attributes: [
                                                     { event_category_id: @ecat.id,
                                                       event_id: @ecat.event.id,
                                                       signed_up: "0"
                                                 }
                                                   ]
                                                 })
      end

      it "creates corresponding registrant_event_sign_ups" do
        expect {
          post 'create', {id: @reg, registrant: @attributes}
        }.to change(RegistrantEventSignUp, :count).by(1)
      end

      it "can update the registrant_event_sign_up" do
        put :update, {id: @reg.to_param, registrant: @attributes}
        expect(response).to redirect_to(registrant_registrant_expense_items_path(@reg))
        @new_attributes[:registrant_event_sign_ups_attributes][0][:id] = RegistrantEventSignUp.first.id
        expect {
          put :update, {id: @reg.to_param, registrant: @new_attributes}
        }.to change(RegistrantEventSignUp, :count).by(0)
        expect(response).to redirect_to(registrant_registrant_expense_items_path(@reg))
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested registrant" do
        registrant = FactoryGirl.create(:competitor, user: @user)
        # Assuming there are no other registrants in the database, this
        # specifies that the Registrant created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        expect_any_instance_of(Registrant).to receive(:update_attributes).with({})
        put :update, {id: registrant.to_param, registrant: {'these' => 'params'}}
      end

      it "assigns the requested registrant as @registrant" do
        registrant = FactoryGirl.create(:competitor, user: @user)
        put :update, {id: registrant.to_param, registrant: valid_attributes}
        expect(assigns(:registrant)).to eq(registrant)
      end

      it "cannot change the competitor to a non-competitor" do
        registrant = FactoryGirl.create(:competitor, user: @user)
        put :update, {id: registrant.to_param, registrant: valid_attributes.merge({registrant_type: 'noncompetitor'})}
        expect(assigns(:registrant)).to eq(registrant)
        expect(assigns(:registrant).competitor).to eq(true)
      end

      it "redirects competitors to the items" do
        registrant = FactoryGirl.create(:competitor, user: @user)
        put :update, {id: registrant.to_param, registrant: valid_attributes}
        expect(response).to redirect_to(registrant_registrant_expense_items_path(Registrant.last))
      end
      it "redirects noncompetitors to the items" do
        registrant = FactoryGirl.create(:noncompetitor, user: @user)
        put :update, {id: registrant.to_param, registrant: valid_attributes}
        expect(response).to redirect_to(registrant_registrant_expense_items_path(Registrant.last))
      end
    end

    describe "with invalid params" do
      let(:registrant) { FactoryGirl.create(:competitor, user: @user) }
      let(:do_action) {
        put :update, {id: registrant.to_param, registrant: {registrant_type: 'competitor'}}
      }
      it "assigns the registrant as @registrant" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Registrant).to receive(:save).and_return(false)
        do_action
        expect(assigns(:registrant)).to eq(registrant)
      end
      it "loads the categories" do
        category1 = FactoryGirl.create(:category)
        allow_any_instance_of(Registrant).to receive(:save).and_return(false)
        do_action
        expect(assigns(:categories)).to eq([category1])
      end

      it "re-renders the 'edit' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Registrant).to receive(:save).and_return(false)
        do_action
        expect(response).to render_template("edit")
      end
    end
  end
end
