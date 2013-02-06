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
      country: "USA",
      club: "TCUC",
      club_contact: "Connie",
      usa_member_number: "12345",
      emergency_name: "Caitlin",
      emergency_relationship: "Sig. Oth.",
      emergency_attending: true,
      emergency_primary_phone: "306-222-1212",
      emergency_other_phone: "911",
      responsible_adult_name: "Andy",
      responsible_adult_phone: "312-555-5555",
      user_id: @user.id,
      birthday: Date.new(1982, 01, 19)
    }
  end

  describe "GET index" do
    it "assigns all registrants as @registrants" do
      registrant = FactoryGirl.create(:competitor, :user => @user)
      other_reg = FactoryGirl.create(:registrant)
      get :index, {}
      assigns(:registrants).should eq([registrant])
    end
    it "assigns the total_owing from the user" do
      registrant = FactoryGirl.create(:competitor, :user => @user)
      get :index, {}
      assigns(:total_owing).should == registrant.amount_owing
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
      get :waiver, {:format => 'pdf', :id => registrant.to_param}
      response.should be_success
      assigns(:registrant).should eq(registrant)
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
      get :new, {}
      assigns(:registrant).should be_a_new(Registrant)
      assigns(:registrant).competitor.should == true
    end
    it "returns a list of all of the events" do
      @category1 = FactoryGirl.create(:category, :position => 1)
      @category3 = FactoryGirl.create(:category, :position => 3)
      @category2 = FactoryGirl.create(:category, :position => 2)

      get 'new', {:id => @reg}
      assigns(:categories).should == [@category1, @category2, @category3]
    end
  end

  describe "GET new_noncompetitor" do
    it "assigns a new noncompetitor as @registrant" do
      get :new_noncompetitor, {}
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

  describe "GET items" do
    it "assigns the requested registrant as @registrant" do
      registrant = FactoryGirl.create(:competitor, :user => @user)
      get :items, {:id => registrant.to_param}
      assigns(:registrant).should eq(registrant)
      response.should be_success
    end
  end

  describe "PUT update_items" do
    it "redirects to the registrant show page" do
      registrant = FactoryGirl.create(:competitor, :user => @user)
      put :update_items, {:id => registrant.to_param}
      response.should redirect_to(registrant)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      before(:each) do
        @comp_attributes = valid_attributes.merge({:competitor => true})
      end
      it "creates a new Registrant" do
        expect {
          post :create, {:registrant => @comp_attributes}
        }.to change(Registrant, :count).by(1)
      end

      it "assigns the registrant to the current user" do
        expect {
          post :create, {:registrant => {
          first_name: "Robin",
          last_name: "Dunlop",
          gender: "Male",
          country: "USA",
          competitor: true,
          birthday: Date.new(1982, 01, 19),
          emergency_name: "Caitlin",
          emergency_relationship: "Sig. Oth.",
          emergency_primary_phone: "306-222-1212",
          user_id: @user.id,
          birthday: Date.new(1982, 01, 19)
          }}
        }.to change(Registrant, :count).by(1)
        Registrant.last.user.should == @user
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
        response.should redirect_to(items_registrant_path(Registrant.last))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved registrant as @registrant" do
        # Trigger the behavior that occurs when invalid params are submitted
        Registrant.any_instance.stub(:save).and_return(false)
        post :create, {:registrant => {}}
        assigns(:registrant).should be_a_new(Registrant)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        Registrant.any_instance.stub(:save).and_return(false)
        post :create, {:registrant => {}}
        response.should render_template("new")
      end
      it "has categories" do
        # Trigger the behavior that occurs when invalid params are submitted
        category1 = FactoryGirl.create(:category, :position => 1)
        Registrant.any_instance.stub(:save).and_return(false)
        post :create, {:registrant => {:competitor => true}}
        assigns(:categories).should == [category1]
      end
      it "should not load categories for a noncompetitor" do
        category1 = FactoryGirl.create(:category, :position => 1)
        Registrant.any_instance.stub(:save).and_return(false)
        post :create, {:registrant => {:competitor => false}}
        assigns(:categories).should == nil
      end
    end
    describe "When creating nested registrant choices" do
      before(:each) do
        @reg = FactoryGirl.create(:registrant)
        @ec1 = FactoryGirl.create(:event_choice)
        @attributes = valid_attributes.merge({
          :competitor => true,
          :registrant_choices_attributes => [
            { :value => "0",
              :event_choice_id => @ec1.id
        }
        ]})
      end

      it "creates a corresponding event_choice when checkbox is selected" do
        post 'create', {:id => @reg, :registrant => @attributes}
        RegistrantChoice.count.should == 1
      end

      it "doesn't create a new entry if one already exists" do
        RegistrantChoice.count.should == 0
        put 'update', {:id => @reg, :registrant => @attributes}
        put 'create', {:id => @reg, :registrant => @attributes}
        RegistrantChoice.count.should == 1
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
        Registrant.any_instance.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, {:id => registrant.to_param, :registrant => {'these' => 'params'}}
      end

      it "assigns the requested registrant as @registrant" do
        registrant = FactoryGirl.create(:competitor, :user => @user)
        put :update, {:id => registrant.to_param, :registrant => valid_attributes}
        assigns(:registrant).should eq(registrant)
      end

      it "redirects competitors to the items" do
        registrant = FactoryGirl.create(:competitor, :user => @user)
        put :update, {:id => registrant.to_param, :registrant => valid_attributes}
        response.should redirect_to(items_registrant_path(Registrant.last))
      end
      it "redirects noncompetitors to the items" do
        registrant = FactoryGirl.create(:noncompetitor, :user => @user)
        put :update, {:id => registrant.to_param, :registrant => valid_attributes}
        response.should redirect_to(items_registrant_path(Registrant.last))
      end
    end

    describe "with invalid params" do
      it "assigns the registrant as @registrant" do
        registrant = FactoryGirl.create(:competitor, :user => @user)
        # Trigger the behavior that occurs when invalid params are submitted
        Registrant.any_instance.stub(:save).and_return(false)
        put :update, {:id => registrant.to_param, :registrant => {}}
        assigns(:registrant).should eq(registrant)
      end
      it "loads the categories" do
        registrant = FactoryGirl.create(:competitor, :user => @user)
        category1 = FactoryGirl.create(:category, :position => 1)
        Registrant.any_instance.stub(:save).and_return(false)
        put :update, {:id => registrant.to_param, :registrant => {}}
        assigns(:categories).should == [category1]
      end

      it "re-renders the 'edit' template" do
        registrant = FactoryGirl.create(:competitor, :user => @user)
        # Trigger the behavior that occurs when invalid params are submitted
        Registrant.any_instance.stub(:save).and_return(false)
        put :update, {:id => registrant.to_param, :registrant => {}}
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    before(:each) do
      sign_in FactoryGirl.create(:admin_user)
    end
    it "destroys the requested registrant" do
      registrant = FactoryGirl.create(:competitor, :user => @user)
      expect {
        delete :destroy, {:id => registrant.to_param}
      }.to change(Registrant, :count).by(-1)
    end

    it "redirects to the registrants list" do
      registrant = FactoryGirl.create(:competitor, :user => @user)
      delete :destroy, {:id => registrant.to_param}
      response.should redirect_to(registrants_url)
    end

    describe "as normal user" do
      before(:each) do
        sign_in @user
      end
      it "cannot destroy a registrat" do
        registrant = FactoryGirl.create(:competitor, :user => @user)
        delete :destroy, {:id => registrant.to_param}
        response.should redirect_to(root_path)
      end
    end
  end

end
