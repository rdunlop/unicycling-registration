require 'spec_helper'

describe "registrants/new" do
  before(:each) do
    assign(:registrant, stub_model(Registrant,
      :first_name => "MyString",
      :middle_initial => "MyString",
      :last_name => "MyString",
      :gender => "MyString",
      :address_line_1 => "MyString",
      :address_line_2 => "MyString",
      :city => "MyString",
      :state => "MyString",
      :country => "MyString",
      :zip_code => "MyString",
      :phone => "MyString",
      :mobile => "MyString",
      :email => "MyString"
    ).as_new_record)
  end

  it "renders new registrant form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => registrants_path, :method => "post" do
      assert_select "input#registrant_first_name", :name => "registrant[first_name]"
      assert_select "input#registrant_middle_initial", :name => "registrant[middle_initial]"
      assert_select "input#registrant_last_name", :name => "registrant[last_name]"
      assert_select "input#registrant_gender_male", :name => "registrant[gender]"
      assert_select "input#registrant_address_line_1", :name => "registrant[address_line_1]"
      assert_select "input#registrant_address_line_2", :name => "registrant[address_line_2]"
      assert_select "input#registrant_city", :name => "registrant[city]"
      assert_select "input#registrant_state", :name => "registrant[state]"
      assert_select "input#registrant_country", :name => "registrant[country]"
      assert_select "input#registrant_zip_code", :name => "registrant[zip_code]"
      assert_select "input#registrant_phone", :name => "registrant[phone]"
      assert_select "input#registrant_mobile", :name => "registrant[mobile]"
      assert_select "input#registrant_email", :name => "registrant[email]"
    end
  end
  describe "registration_periods/_list" do
    before(:each) do
      @registration_period = FactoryGirl.create(:registration_period, 
                                                :start_date => Date.new(2012, 01, 10),
                                                :end_date => Date.new(2012, 02, 11),
                                                :competitor_cost => 100,
                                                :noncompetitor_cost => 50)
    end

    it "renders dates in nice formats" do
      render
      # Run the generator again with the --webrat flag if you want to use webrat matchers
      rendered.should match(/Jan 10, 2012/)
      rendered.should match(/Feb 11, 2012/)
    end
    it "lists competitor costs" do
      render
      render.should match(/\$100/)
    end
  end
end
