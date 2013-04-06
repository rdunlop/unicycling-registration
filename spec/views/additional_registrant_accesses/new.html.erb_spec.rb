require 'spec_helper'

describe "additional_registrant_accesses/new" do
  before(:each) do
    assign(:additional_registrant_access, stub_model(AdditionalRegistrantAccess,
      :user_id => 1,
      :registrant_id => 1,
      :declined => false,
      :accepted_readonly => false
    ).as_new_record)
    @user = FactoryGirl.create(:user) 
  end

  it "renders new additional_registrant_access form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => user_additional_registrant_accesses_path(@user), :method => "post" do
      assert_select "select#additional_registrant_access_registrant_id", :name => "additional_registrant_access[registrant_id]"
    end
  end
end
