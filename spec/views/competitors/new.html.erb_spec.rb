require 'spec_helper'

describe "competitors/new" do
    before(:each) do
      comp = assign(:competitor, FactoryGirl.build(:event_competitor))
      @ec = comp.event_category
      assign(:event_category, @ec)
    end

    it "renders new competitor form" do
      render

      # Run the generator again with the --webrat flag if you want to use webrat matchers
      assert_select "form", :action => new_event_category_competitor_path(@ec), :method => "post" do
        assert_select "select#competitor_registrant_ids", :name => "competitor[registrant_ids][]"
        assert_select "input#competitor_position", :name => "competitor[position]"
        assert_select "input#competitor_custom_external_id", :name => "competitor[custom_external_id]"
        assert_select "input#competitor_custom_name", :name => "competitor[custom_name]"
      end
    end
end
