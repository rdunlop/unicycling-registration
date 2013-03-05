require 'spec_helper'

describe Admin::StandardSkillRoutinesController do
  before (:each) do
    @super_admin_user = FactoryGirl.create(:super_admin_user)
    sign_in @super_admin_user
  end

  # This should return the minimal set of attributes required to create a valid
  # Registrant. As you add validations to Registrant, be sure to
  # update the return value of this method accordingly.
  def valid_attributes
    {
      }
  end

  describe "GET download_file" do
    before(:each) do
      @initial_entry = FactoryGirl.create(:standard_skill_routine_entry)
      @next_entry = FactoryGirl.create(:standard_skill_routine_entry)
    end
    it "downloads the standard_skill_routine_entries for everyone" do
      get :download_file
      csv = CSV.parse(response.body, :headers => true)

      csv.count.should == 2

      row1 = csv[0]
      row1.count.should == 4
      row1[0].should == @initial_entry.standard_skill_routine.registrant.external_id.to_s
      row1[1].should == @initial_entry.position.to_s
      row1[2].should == @initial_entry.standard_skill_entry.number.to_s
      row1[3].should == @initial_entry.standard_skill_entry.letter.to_s

      row2 = csv[1]
      row2.count.should == 4
      row2[0].should == @next_entry.standard_skill_routine.registrant.external_id.to_s
      row2[1].should == @next_entry.position.to_s
      row2[2].should == @next_entry.standard_skill_entry.number.to_s
      row2[3].should == @next_entry.standard_skill_entry.letter.to_s
    end

    it "should fail for non-admin user" do
      @user = FactoryGirl.create(:user)
      sign_in @user

      get :download_file

      response.should redirect_to(root_path)
    end
  end
end
