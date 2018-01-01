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
        get :show, params: { registrant_id: registrant.to_param, id: "add_contact_details" }
        expect(response).to be_success
      end
    end

    context "viewing the lodging page" do
      let(:registrant) { FactoryGirl.create(:competitor, status: "contact_details", user: user) }
      let!(:lodging_day) { FactoryGirl.create(:lodging_day) }

      it "displays the add-lodging form" do
        get :show, params: { registrant_id: registrant.to_param, id: "lodging" }
        assert_select "fieldset" do
          assert_select "legend", text: "Add Lodging"
        end
      end
    end

    context "viewing the expenses page" do
      let(:registrant) { FactoryGirl.create(:competitor, status: "contact_details", user: user) }
      let!(:group) { FactoryGirl.create(:expense_group) }
      let!(:item1) { FactoryGirl.create(:expense_item, expense_group: group) }
      let!(:item2) { FactoryGirl.create(:expense_item, expense_group: group) }

      let!(:group2) { FactoryGirl.create(:expense_group, position: 2, visible: false) }
      let!(:item3) { FactoryGirl.create(:expense_item, expense_group: group2) }

      it "displays the add-expenses form" do
        get :show, params: { registrant_id: registrant.to_param, id: "expenses" }
        assert_select "fieldset" do
          assert_select "legend", text: "Add " + group.group_name
          assert_select "td", text: item1.name
          assert_select "td", text: item3.name, count: 0
        end
      end

      it "should render the details field, if enabled" do
        @item = FactoryGirl.create(:registrant_expense_item, registrant: registrant)
        ei = @item.line_item
        ei.has_details = true
        ei.details_label = "What is your family?"
        ei.save!

        get :show, params: { registrant_id: registrant.to_param, id: "expenses" }

        assert_select "label", text: "What is your family?"
        assert_select "input#registrant_expense_item_details", name: "registrant_expense_item[details]"
      end
    end

    context "viewing the add_name page" do
      let(:registrant) { FactoryGirl.create(:competitor, status: "contact_details", user: user) }

      before do
        @comp_exp = FactoryGirl.create(:expense_item, cost: 100)
        @noncomp_exp = FactoryGirl.create(:expense_item, cost: 50)
        FactoryGirl.create(:registration_cost, :competitor,
                           start_date: Date.new(2012, 1, 10),
                           end_date: Date.new(2012, 2, 11),
                           expense_item: @comp_exp)
        FactoryGirl.create(:registration_cost, :noncompetitor,
                           start_date: Date.new(2012, 1, 10),
                           end_date: Date.new(2012, 2, 11),
                           expense_item: @noncomp_exp)
        FactoryGirl.create(:wheel_size_24, id: 3)
      end

      it "renders dates in nice formats" do
        get :show, params: { registrant_id: registrant.to_param, id: "add_name" }

        # Need specific registration_cost periods for these dates
        assert_match(/Jan 10, 2012/, response.body)
        assert_match(/Feb 11, 2012/, response.body)
      end

      it "lists competitor costs" do
        get :show, params: { registrant_id: registrant.to_param, id: "add_name" }

        assert_match(/100/, response.body)
      end

      describe "as non-competitor" do
        let(:registrant) { FactoryGirl.create(:noncompetitor, status: "contact_details", user: user) }

        it "displays the registration_period for non-competitors" do
          get :show, params: { registrant_id: registrant.to_param, id: "add_name" }

          assert_match(/50/, response.body)
        end
      end
    end
  end

  describe "POST create" do
    before(:each) do
      @ws20 = FactoryGirl.create(:wheel_size_20)
      @ws24 = FactoryGirl.create(:wheel_size_24)
    end

    context "when creating with copy-from-previous convention" do
      before do
        Apartment::Tenant.create("other")
        Apartment::Tenant.switch "other" do
          @other_reg = FactoryGirl.create(:competitor, user: user)
        end
      end
      after do
        Apartment::Tenant.drop("other")
      end

      let(:previous_reg_reference) { RegistrantCopier.build_key("other", @other_reg.id) }

      it "can create a competitor based on a previous convention record" do
        expect do
          post :create_from_previous, params: { registrant: { registrant_type: "competitor" }, registrant_id: "new", previous_registrant: previous_reg_reference}
        end.to change(Registrant, :count).by(1)
        expect(Registrant.last.contact_detail).not_to be_nil
      end
    end

    describe "with valid params" do
      before(:each) do
        @comp_attributes = valid_attributes.merge(registrant_type: 'competitor')
      end
      let(:params) do
        {
          registrant_type: "competitor",
          first_name: "Bob",
          last_name: "Smith",
          "birthday(2i)" => "1",
          "birthday(3i)" => "13",
          "birthday(1i)" => "1995",
          gender: "Male"
        }
      end
      it "creates a new Registrant" do
        expect do
          post :create, params: { registrant_id: "new", registrant: params }
        end.to change(Registrant, :count).by(1)
      end

      it "assigns the registrant to the current user" do
        expect do
          post :create, params: { registrant_id: "new", registrant: params }
        end.to change(Registrant, :count).by(1)
        expect(Registrant.last.user).to eq(user)
      end

      it "sets the registrant as a competitor" do
        post :create, params: { registrant_id: "new", registrant: @comp_attributes }
        expect(Registrant.last.competitor?).to eq(true)
      end

      it "redirects to the created registrant" do
        post :create, params: { registrant_id: "new", registrant: @comp_attributes }
        expect(response).to redirect_to(registrant_build_path(Registrant.last.to_param, :add_events))
      end
    end

    describe "with invalid params" do
      it "does not create a new registrant" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Registrant).to receive(:save).and_return(false)
        expect do
          post :create, params: { registrant_id: "new", registrant: {registrant_type: 'competitor'} }
        end.not_to change(Registrant, :count)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Registrant).to receive(:save).and_return(false)
        post :create, params: { registrant_id: "new", registrant: {registrant_type: 'competitor'} }
        expect(response).to redirect_to(new_registrant_path(registrant_type: 'competitor', copy_from_previous: false))
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
                                                 event_id: @ev.id}
                                             ],
                                             registrant_choices_attributes: [
                                               { event_choice_id: @ec.id,
                                                 value: "1"}
                                             ])
      end

      it "creates a corresponding event_choice when checkbox is selected" do
        expect do
          post :create, params: { registrant_id: "new", registrant: @attributes }
        end.to change(RegistrantChoice, :count).by(1)
      end

      xit "doesn't create a new entry if one already exists" do
        expect(RegistrantChoice.count).to eq(0)
        put :update, params: { registrant_id: @reg.to_param, registrant: @attributes }
        expect(RegistrantChoice.count).to eq(1)
      end
      it "can update an existing registrant_choice" do
        put :update, params: { registrant_id: @reg.to_param, id: "add_events", registrant: @attributes }
        @attributes[:registrant_event_sign_ups_attributes][0][:id] = RegistrantEventSignUp.first.id
        @attributes[:registrant_choices_attributes][0][:id] = RegistrantChoice.first.id
        put :update, params: { registrant_id: @reg.to_param, id: "add_events", registrant: @attributes }
        expect(response).to redirect_to(registrant_build_path(@reg.to_param, :add_volunteers))
      end
    end

    xdescribe "when creating registrant_event_sign_ups" do
      before(:each) do
        @reg = FactoryGirl.create(:registrant, user: user)
        @ecat = FactoryGirl.create(:event).event_categories.first
        @attributes = valid_attributes.merge(registrant_type: 'competitor',
                                             registrant_event_sign_ups_attributes: [
                                               { event_category_id: @ecat.id,
                                                 event_id: @ecat.event.id,
                                                 signed_up: "1"}
                                             ])
        @new_attributes = valid_attributes.merge(registrant_type: 'competitor',
                                                 registrant_event_sign_ups_attributes: [
                                                   { event_category_id: @ecat.id,
                                                     event_id: @ecat.event.id,
                                                     signed_up: "0"}
                                                 ])
      end

      it "creates corresponding registrant_event_sign_ups" do
        expect do
          post :create, params: { registrant_id: @reg, id: "new", registrant: @attributes }
        end.to change(RegistrantEventSignUp, :count).by(1)
      end

      it "can update the registrant_event_sign_up" do
        put :update, params: { registrant_id: @reg.to_param, id: "add_events", registrant: @attributes }
        expect(response).to redirect_to(registrant_registrant_expense_items_path(@reg))
        @new_attributes[:registrant_event_sign_ups_attributes][0][:id] = RegistrantEventSignUp.first.id
        expect do
          put :update, params: { registrant_id: @reg.to_param, id: "add_events", registrant: @new_attributes }
        end.to change(RegistrantEventSignUp, :count).by(0)
        expect(response).to redirect_to(registrant_registrant_expense_items_path(@reg))
      end
    end
  end

  describe "PUT update" do
    def valid_attributes
      {
        first_name: "Robin",
        last_name: "Dunlop",
        gender: "Male",
        birthday: Date.new(1982, 1, 19)
      }
    end

    context "when registrant is copied from a previous convention" do
      let(:registrant) { FactoryGirl.create(:competitor, user: user, status: "base_details") }

      before do
        # Copied from previous convention don't have these fields
        cd = registrant.contact_detail
        cd.emergency_relationship = nil
        cd.emergency_name = nil
        cd.save(validate: false)
      end

      context "when starting on the new_name page" do
        it "redirects to the next page" do
          put :update, params: { registrant_id: registrant.to_param, id: "add_name", registrant: valid_attributes }
          expect(response).to redirect_to(registrant_build_path(registrant.to_param, :add_events))
        end
      end

      context "When we are using USA organization_membership_usa" do
        let(:event_configuration) { FactoryGirl.create(:event_configuration, :with_usa) }

        context "when starting on the new_name page" do
          it "redirects to the next page" do
            put :update, params: { registrant_id: registrant.to_param, id: "add_name", registrant: valid_attributes }
            expect(response).to redirect_to(registrant_build_path(registrant.to_param, :add_events))
          end
        end
      end
    end
  end

  xdescribe "PUT update" do
    describe "with valid params" do
      it "assigns the requested registrant as @registrant" do
        registrant = FactoryGirl.create(:competitor, user: user)
        put :update, params: { registrant_id: registrant.to_param, id: "add_name", registrant: valid_attributes }
        expect(assigns(:registrant)).to eq(registrant)
      end

      it "cannot change the competitor to a non-competitor" do
        registrant = FactoryGirl.create(:competitor, user: user)
        put :update, params: { registrant_id: registrant.to_param, id: "add_name", registrant: valid_attributes.merge(registrant_type: 'noncompetitor') }
        expect(assigns(:registrant)).to eq(registrant)
        expect(assigns(:registrant).competitor?).to eq(true)
      end

      it "redirects competitors to the items" do
        registrant = FactoryGirl.create(:competitor, user: user)
        put :update, params: { registrant_id: registrant.to_param, id: "add_name", registrant: valid_attributes }
        expect(response).to redirect_to(registrant_registrant_expense_items_path(Registrant.last))
      end
      it "redirects noncompetitors to the items" do
        registrant = FactoryGirl.create(:noncompetitor, user: user)
        put :update, params: { registrant_id: registrant.to_param, id: "add_name", registrant: valid_attributes }
        expect(response).to redirect_to(registrant_registrant_expense_items_path(Registrant.last))
      end
    end

    describe "with invalid params" do
      let(:registrant) { FactoryGirl.create(:competitor, user: user) }
      let(:do_action) do
        put :update, params: { registrant_id: registrant.to_param, id: "add_name", registrant: {registrant_type: 'competitor'} }
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
      delete :drop_event, params: { registrant_id: registrant.bib_number, event_id: event.id }
      expect(registrant.reload.registrant_event_sign_ups.find_by(event: event).signed_up).to be_falsey
    end
  end
end
