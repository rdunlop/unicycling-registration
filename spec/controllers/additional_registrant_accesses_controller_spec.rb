require 'spec_helper'

describe AdditionalRegistrantAccessesController do
  before(:each) do
    @reg = FactoryGirl.create(:registrant)
    @user = FactoryGirl.create(:user)
    sign_in @user
  end

  # This should return the minimal set of attributes required to create a valid
  # AdditionalRegistrantAccess. As you add validations to AdditionalRegistrantAccess, be sure to
  # update the return value of this method accordingly.
  def valid_attributes
    { "registrant_id" => @reg.id }
  end

  describe "GET index" do
    it "assigns all additional_registrant_accesses as @additional_registrant_accesses" do
      additional_registrant_access = FactoryGirl.create(:additional_registrant_access, :user => @user, :registrant => @reg)
      get :index, {:user_id => @user.id}
      expect(assigns(:additional_registrant_accesses)).to eq([additional_registrant_access])
    end
  end

  describe "GET invitations" do
    it "assigns all invitations for me to @invitations" do
      my_reg = FactoryGirl.create(:registrant, :user => @user)
      ada = FactoryGirl.create(:additional_registrant_access, :registrant => my_reg)
      get :invitations, {:user_id => @user.id}
      expect(assigns(:additional_registrant_accesses)).to eq([ada])
    end
    it "doesn't assign other people's invitations" do
      ada = FactoryGirl.create(:additional_registrant_access)
      get :invitations, {:user_id => @user.id}
      expect(assigns(:additional_registrant_accesses)).to eq([])
    end
  end

  describe "GET new" do
    it "assigns a new additional_registrant_access as @additional_registrant_access" do
      get :new, {:user_id => @user.id}
      expect(assigns(:additional_registrant_access)).to be_a_new(AdditionalRegistrantAccess)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new AdditionalRegistrantAccess" do
        expect {
          post :create, {:user_id => @user.id, :additional_registrant_access => valid_attributes}
        }.to change(AdditionalRegistrantAccess, :count).by(1)
      end

      it "assigns a newly created additional_registrant_access as @additional_registrant_access" do
        post :create, {:user_id => @user.id, :additional_registrant_access => valid_attributes}
        expect(assigns(:additional_registrant_access)).to be_persisted
      end

      it "redirects to the created additional_registrant_access" do
        post :create, {:user_id => @user.id, :additional_registrant_access => valid_attributes}
        expect(response).to redirect_to(user_additional_registrant_accesses_path(@user))
      end
      it "creates an e-mail to the target registrants' user" do
        ActionMailer::Base.deliveries.clear
        post :create, {:user_id => @user.id, :additional_registrant_access => valid_attributes}
        num_deliveries = ActionMailer::Base.deliveries.size
        expect(num_deliveries).to eq(1)
        mail = ActionMailer::Base.deliveries.first
        expect(mail.to).to eq([@reg.user.email])
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved additional_registrant_access as @additional_registrant_access" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(AdditionalRegistrantAccess).to receive(:save).and_return(false)
        post :create, {:user_id => @user.id, :additional_registrant_access => { "registrant_id" => "invalid value" }}
        expect(assigns(:additional_registrant_access)).to be_a_new(AdditionalRegistrantAccess)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(AdditionalRegistrantAccess).to receive(:save).and_return(false)
        post :create, {:user_id => @user.id, :additional_registrant_access => { "registrant_id" => "invalid value" }}
        expect(response).to render_template("new")
      end
    end
  end

  describe "PUT accepted_readonly" do
    describe "with a request" do
      before(:each) do
        @additional_registrant_access = FactoryGirl.create(:additional_registrant_access, :user => @user, :registrant => @reg)
      end

      it "cannot accept its own invitation" do
        expect {
          put :accept_readonly, {:id => @additional_registrant_access.to_param}
        }.to_not change(@additional_registrant_access, :accepted_readonly)
      end
      it "redirects to the root if unauthorized" do
        put :accept_readonly, {:id => @additional_registrant_access.to_param}
        expect(response).to redirect_to(root_path)
      end

      describe "when signed in as the target of the invitation" do
        before(:each) do
          sign_out @user
          sign_in @reg.user
        end

        it "allows the registrant's user to accept the invitation" do
          expect {
            put :accept_readonly, {:id => @additional_registrant_access.to_param}
          }.to_not change(@additional_registrant_access, :accepted_readonly)
        end
        it "creates an e-mail to the requesting user" do
          ActionMailer::Base.deliveries.clear
          put :accept_readonly, {:id => @additional_registrant_access.to_param}
          num_deliveries = ActionMailer::Base.deliveries.size
          expect(num_deliveries).to eq(1)
          mail = ActionMailer::Base.deliveries.first
          expect(mail.to).to eq([@user.email])
        end
      end
    end
  end

  describe "DELETE decline" do
    it "dosen't allow the creator to decline the invitation" do
      additional_registrant_access = FactoryGirl.create(:additional_registrant_access, :user => @user, :registrant => @reg)

      delete :decline, {:id => additional_registrant_access.to_param}
      expect(additional_registrant_access.reload.declined).to eq(false)
    end
    it "decline the requested additional_registrant_access" do
      sign_out @user
      sign_in @reg.user
      additional_registrant_access = FactoryGirl.create(:additional_registrant_access, :user => @user, :registrant => @reg)

      expect(additional_registrant_access.declined).to eq(false)
      delete :decline, {:id => additional_registrant_access.to_param}
      expect(additional_registrant_access.reload.declined).to eq(true)
    end

    it "redirects to the additional_registrant_accesses list" do
      sign_out @user
      sign_in @reg.user
      additional_registrant_access = FactoryGirl.create(:additional_registrant_access, :user => @user, :registrant => @reg)
      delete :decline, {:id => additional_registrant_access.to_param}
      expect(response).to redirect_to(invitations_user_additional_registrant_accesses_path(@reg.user))
    end
  end

end
