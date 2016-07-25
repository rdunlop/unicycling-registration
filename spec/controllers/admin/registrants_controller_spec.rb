require 'spec_helper'

describe Admin::RegistrantsController do
  before(:each) do
    @user = FactoryGirl.create(:user)
    sign_in @user
  end

  describe "with a super admin user" do
    before(:each) do
      sign_out @user
      @admin_user = FactoryGirl.create(:super_admin_user)
      sign_in @admin_user
    end

    describe "GET manage_all" do
      it "assigns all registrants as @registrants" do
        registrant = FactoryGirl.create(:competitor)
        other_reg = FactoryGirl.create(:registrant)
        get :manage_all
        expect(assigns(:registrants)).to match_array([registrant, other_reg])
      end
    end

    describe "GET manage_one" do
      it "renders" do
        get :manage_one
        expect(response).to be_success
      end
    end

    describe "POST choose_one" do
      let(:summary) { "0" }
      let(:bib_number) { nil }
      let(:registrant_id) { nil }
      let(:registrant) { FactoryGirl.create(:registrant) }

      before { request.env["HTTP_REFERER"] = root_path }
      before { post :choose_one, bib_number: bib_number, registrant_id: registrant_id, summary: summary }

      context "with a bib_number" do
        context "with a matching bib_number" do
          let(:bib_number) { registrant.bib_number}

          it "sends to the build path" do
            expect(response).to redirect_to(registrant_build_path(registrant, :add_name))
          end
        end
      end

      context "without a bib_number or registrant_id" do
        it "redirects to back" do
          expect(response).to redirect_to(root_path)
        end
      end

      context "with a registrant" do
        let(:registrant_id) { registrant.id }

        it "sends me to the registrant name build path" do
          expect(response).to redirect_to(registrant_build_path(registrant, :add_name))
        end

        context "when choosing summary mode" do
          let(:summary) { "1" }

          it "sends me to the show page" do
            expect(response).to redirect_to(registrant_path(registrant))
          end
        end
      end
    end

    context "with some registrants" do
      before do
        FactoryGirl.create_list(:registrant, 3)
      end
      describe "GET show_all" do
        it "renders in normal order" do
          get :show_all, format: :pdf
          expect(response).to redirect_to(reports_path)
        end

        it "renders in id order" do
          get :show_all, order: "id", format: :pdf
          expect(response).to redirect_to(reports_path)
        end

        it "renders in id order with offset" do
          get :show_all, order: "id", offset: "20", max: "5", format: :pdf
          expect(response).to redirect_to(reports_path)
        end
      end

      describe "GET bag_labels" do
        it "renders" do
          get :bag_labels
          expect(response).to be_success
        end
      end
    end

    describe "POST undelete" do
      before(:each) do
        FactoryGirl.create(:registration_cost)
      end
      it "un-deletes a deleted registration" do
        registrant = FactoryGirl.create(:competitor, deleted: true)
        post :undelete, id: registrant.to_param
        registrant.reload
        expect(registrant.deleted).to eq(false)
      end

      it "redirects to the root" do
        registrant = FactoryGirl.create(:competitor, deleted: true)
        post :undelete, id: registrant.to_param
        expect(response).to redirect_to(manage_all_registrants_path)
      end

      describe "as a normal user" do
        before(:each) do
          @user = FactoryGirl.create(:user)
          sign_in @user
        end
        it "Cannot undelete a user" do
          registrant = FactoryGirl.create(:competitor, deleted: true)
          post :undelete, id: registrant.to_param
          registrant.reload
          expect(registrant.deleted).to eq(true)
        end
      end
    end
  end
end
