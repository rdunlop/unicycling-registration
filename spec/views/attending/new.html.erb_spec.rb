require 'spec_helper'

describe "attending/new.html.erb" do
  before(:each) do
    @registrant = FactoryGirl.create(:registrant)

    @ev1 = FactoryGirl.create(:event)
    @categories = [@ev1.category]

  end

  describe "for a boolean choice" do
    before(:each) do
      @ec1 = FactoryGirl.create(:event_choice, :event => @ev1)
      rc = @registrant.registrant_choices.build
      rc.event_choice_id = @ec1.id
    end
    it "should have the checkbox" do
      render

      # Run the generator again with the --webrat flag if you want to use webrat matchers
      assert_select "form", :action => attending_index_path(@registrant), :method => "post" do
        assert_select "input#registrant_registrant_choices_attributes_0_event_choice_id", :name => "registrant[registrant_choices_attributes][0][event_choice_id]" do
          assert_select "input[value='#{@ec1.id}']"
        end
        assert_select "input#registrant_registrant_choices_attributes_0_value", :name => "registrant[registrant_choices_attributes][0][value]" do
          assert_select "input[value='1']"
        end
      end
    end
    describe "With existing selections" do
      before(:each) do
        @rc = FactoryGirl.create(:registrant_choice, :value => "1")
        @registrant = @rc.registrant
        @attending = @rc
        @categories = [@rc.event_choice.event.category]

        @ec1 = @rc.event_choice
      end

      it "displays the checkbox as checked off" do
        render

        assert_select "form", :action => attending_index_path(@registrant), :method => "post" do
          assert_select "input[type='checkbox']", 1 do
            assert_select "[checked='checked']", 1
          end
        end
      end
      it "renders as not-checked-off if value is '0'" do
        @rc.value = "0"
        @rc.save
        render

        assert_select "form", :action => attending_index_path(@registrant), :method => "post" do
          assert_select "input[type='checkbox']", 1 do
            assert_select "[checked='checked']", 0
          end
        end
      end

      it "displays a hidden form field" do
        render

        assert_select "form" do
          assert_select "input[type='hidden'][name='registrant[registrant_choices_attributes][0][value]']"
        end
      end
    end
  end

  describe "for a text choice" do
    before(:each) do
      @ec1 = FactoryGirl.create(:event_choice, :event => @ev1, :cell_type => "text", :position => 2)
      rc = @registrant.registrant_choices.build
      rc.event_choice_id = @ec1.id
    end
    it "should have the text input" do
      render

      assert_select "form", :action => attending_index_path(@registrant), :method => "post" do
        assert_select "input#registrant_registrant_choices_attributes_0_event_choice_id", :name => "registrant[registrant_choices_attributes][0][event_choice_id]" do
          assert_select "input[value='#{@ec1.id}']"
        end
        assert_select "input#registrant_registrant_choices_attributes_0_value", :name => "registrant[registrant_choices_attributes][0][value]" do
          assert_select "input[type='text']", 1
        end
      end
    end
    describe "for already present choice" do
      before(:each) do
        @rc = FactoryGirl.create(:registrant_choice, :event_choice => @ec1, :registrant => @registrant, :value => "Hello")
      end
      it "displays the text if already present in user's choice" do
        render

        assert_select "input#registrant_registrant_choices_attributes_0_value", :name => "registrant[registrant_choices_attributes][0][value]" do
          assert_select "input[type='text'][value='Hello']", 1
        end
      end
    end
  end

  describe "for multiple choice" do
    before(:each) do
      @ec1 = FactoryGirl.create(:event_choice, :event => @ev1, :cell_type => "multiple", :multiple_values => "one, two, three", :position => 2)
    end

    it "presents me with a select box" do
      render

      assert_select "select", 1
    end

    it "has the 3+1(blank) values as options" do
      render

      assert_select "select" do
        assert_select "option", 4
        assert_select "option[value='one']"
        assert_select "option[value='two']"
        assert_select "option[value='three']"
      end
    end
  end
end
