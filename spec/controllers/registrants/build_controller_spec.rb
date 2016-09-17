require 'spec_helper'

describe Registrants::BuildController do
  let(:user) { FactoryGirl.create(:user) }
  before(:each) do
    sign_in user

    allow_any_instance_of(EventConfiguration).to receive(:registration_closed?).and_return(false)
    allow_any_instance_of(EventConfiguration).to receive(:organization_membership_config?).and_return(true)
    allow_any_instance_of(EventConfiguration).to receive(:organization_membership_usa?).and_return(true)
  end

  # This should return the minimal set of attributes required to create a valid
  # Registrant. As you add validations to Registrant, be sure to
  # update the return value of this method accordingly.
  def valid_attributes
    {
      first_name: "Robin",
      last_name: "Dunlop",
      gender: "Male",
      user_id: user.id,
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
        email: "fake@example.com",
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

  describe "GET show" do
    context "viewing the add_contact_details page" do
      let(:registrant) { FactoryGirl.create(:competitor, status: "contact_details", user: user) }

      it "displays the contact detail form" do
        get :show, registrant_id: registrant.to_param, id: "add_contact_details"
        expect(response).to be_success
      end
    end
  end

  xdescribe "POST create" do
    describe "with valid params" do
      before(:each) do
        @ws20 = FactoryGirl.create(:wheel_size_20)
        @ws24 = FactoryGirl.create(:wheel_size_24)
        @comp_attributes = valid_attributes.merge(registrant_type: 'competitor')
      end
      it "creates a new Registrant" do
        expect do
          post :create, registrant_id: "new", registrant: @comp_attributes
        end.to change(Registrant, :count).by(1)
      end

      it "assigns the registrant to the current user" do
        expect do
          post :create, registrant_id: "new", registrant: valid_attributes.merge(
            registrant_type: 'competitor')
        end.to change(Registrant, :count).by(1)
        expect(Registrant.last.user).to eq(user)
        expect(Registrant.last.contact_detail).not_to be_nil
      end

      it "sets the registrant as a competitor" do
        post :create, registrant_id: "new", registrant: @comp_attributes
        expect(Registrant.last.competitor?).to eq(true)
      end

      it "assigns a newly created registrant as @registrant" do
        post :create, registrant_id: "new", registrant: @comp_attributes
        expect(assigns(:registrant)).to be_a(Registrant)
        expect(assigns(:registrant)).to be_persisted
      end

      it "redirects to the created registrant" do
        post :create, registrant_id: "new", registrant: @comp_attributes
        expect(response).to redirect_to(registrant_registrant_expense_items_path(Registrant.last))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved registrant as @registrant" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Registrant).to receive(:save).and_return(false)
        post :create, registrant_id: "new", registrant: {registrant_type: 'competitor'}
        expect(assigns(:registrant)).to be_a_new(Registrant)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Registrant).to receive(:save).and_return(false)
        post :create, registrant_id: "new", registrant: {registrant_type: 'competitor'}
        expect(response).to render_template("new")
      end
      it "has categories" do
        # Trigger the behavior that occurs when invalid params are submitted
        category1 = FactoryGirl.create(:category)
        allow_any_instance_of(Registrant).to receive(:save).and_return(false)
        post :create, registrant_id: "new", registrant: {registrant_type: 'competitor'}
        expect(assigns(:categories)).to eq([category1])
      end
      it "should not load categories for a noncompetitor" do
        FactoryGirl.create(:category)
        allow_any_instance_of(Registrant).to receive(:save).and_return(false)
        post :create, registrant_id: "new", registrant: {registrant_type: 'noncompetitor'}
        expect(assigns(:categories)).to be_nil
      end
    end
    describe "When creating nested registrant choices" do
      before(:each) do
        @reg = FactoryGirl.create(:registrant, user: user)
        @ev = FactoryGirl.create(:event)
        @ec = FactoryGirl.create(:event_choice, event: @ev)
        @attributes = valid_attributes.merge(registrant_type: 'competitor',
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
                                             ])
      end

      it "creates a corresponding event_choice when checkbox is selected" do
        expect do
          post 'create', registrant_id: "new", registrant: @attributes
        end.to change(RegistrantChoice, :count).by(1)
      end

      it "doesn't create a new entry if one already exists" do
        expect(RegistrantChoice.count).to eq(0)
        put :update, registrant_id: @reg.to_param, registrant: @attributes
        expect(RegistrantChoice.count).to eq(1)
      end
      it "can update an existing registrant_choice" do
        put :update, registrant_id: @reg.to_param, id: "add_events", registrant: @attributes
        @attributes[:registrant_event_sign_ups_attributes][0][:id] = RegistrantEventSignUp.first.id
        @attributes[:registrant_choices_attributes][0][:id] = RegistrantChoice.first.id
        put :update, registrant_id: @reg.to_param, id: "add_events", registrant: @attributes
        expect(response).to redirect_to(registrant_registrant_expense_items_path(@reg))
      end
    end

    describe "when creating registrant_event_sign_ups" do
      before(:each) do
        @reg = FactoryGirl.create(:registrant, user: user)
        @ecat = FactoryGirl.create(:event).event_categories.first
        @attributes = valid_attributes.merge(registrant_type: 'competitor',
                                             registrant_event_sign_ups_attributes: [
                                               { event_category_id: @ecat.id,
                                                 event_id: @ecat.event.id,
                                                 signed_up: "1"
                                           }
                                             ])
        @new_attributes = valid_attributes.merge(registrant_type: 'competitor',
                                                 registrant_event_sign_ups_attributes: [
                                                   { event_category_id: @ecat.id,
                                                     event_id: @ecat.event.id,
                                                     signed_up: "0"
                                               }
                                                 ])
      end

      it "creates corresponding registrant_event_sign_ups" do
        expect do
          post :create, registrant_id: @reg, id: "new", registrant: @attributes
        end.to change(RegistrantEventSignUp, :count).by(1)
      end

      it "can update the registrant_event_sign_up" do
        put :update, registrant_id: @reg.to_param, id: "add_events", registrant: @attributes
        expect(response).to redirect_to(registrant_registrant_expense_items_path(@reg))
        @new_attributes[:registrant_event_sign_ups_attributes][0][:id] = RegistrantEventSignUp.first.id
        expect do
          put :update, registrant_id: @reg.to_param, id: "add_events", registrant: @new_attributes
        end.to change(RegistrantEventSignUp, :count).by(0)
        expect(response).to redirect_to(registrant_registrant_expense_items_path(@reg))
      end
    end
  end

  xdescribe "PUT update" do
    describe "with valid params" do
      it "updates the requested registrant" do
        registrant = FactoryGirl.create(:competitor, user: user)
        # Assuming there are no other registrants in the database, this
        # specifies that the Registrant created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        expect_any_instance_of(Registrant).to receive(:update_attributes).with({})
        put :update, registrant_id: registrant.to_param, id: "add_name", registrant: {'these' => 'params'}
      end

      it "assigns the requested registrant as @registrant" do
        registrant = FactoryGirl.create(:competitor, user: user)
        put :update, registrant_id: registrant.to_param, id: "add_name", registrant: valid_attributes
        expect(assigns(:registrant)).to eq(registrant)
      end

      it "cannot change the competitor to a non-competitor" do
        registrant = FactoryGirl.create(:competitor, user: user)
        put :update, registrant_id: registrant.to_param, id: "add_name", registrant: valid_attributes.merge(registrant_type: 'noncompetitor')
        expect(assigns(:registrant)).to eq(registrant)
        expect(assigns(:registrant).competitor?).to eq(true)
      end

      it "redirects competitors to the items" do
        registrant = FactoryGirl.create(:competitor, user: user)
        put :update, registrant_id: registrant.to_param, id: "add_name", registrant: valid_attributes
        expect(response).to redirect_to(registrant_registrant_expense_items_path(Registrant.last))
      end
      it "redirects noncompetitors to the items" do
        registrant = FactoryGirl.create(:noncompetitor, user: user)
        put :update, registrant_id: registrant.to_param, id: "add_name", registrant: valid_attributes
        expect(response).to redirect_to(registrant_registrant_expense_items_path(Registrant.last))
      end
    end

    describe "with invalid params" do
      let(:registrant) { FactoryGirl.create(:competitor, user: user) }
      let(:do_action) do
        put :update, registrant_id: registrant.to_param, id: "add_name", registrant: {registrant_type: 'competitor'}
      end
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

  describe "DELETE drop_event" do
    let(:event) { FactoryGirl.create(:event) }
    let(:registrant) { FactoryGirl.create(:competitor, user: user) }
    let(:event_choice) { FactoryGirl.create(:event_choice, event: event) }
    let(:event_category) { event.event_categories.first }
    let!(:resu) { FactoryGirl.create(:registrant_event_sign_up, event: event, event_category: event_category, registrant: registrant) }

    it "sign out for event" do
      delete :drop_event, registrant_id: registrant.bib_number, event_id: event.id
      expect(registrant.reload.registrant_event_sign_ups.find_by(event: event).signed_up).to be_falsey
    end
  end
end
