require 'spec_helper'

describe "attending/new.html.erb" do
  before(:each) do
    @registrant = FactoryGirl.create(:registrant)

    @ev1 = FactoryGirl.create(:event)
    @ev2 = FactoryGirl.create(:event)
    @events = [@ev1, @ev2]

    @ec1 = FactoryGirl.create(:event_choice, :event => @ev1)
    @ec2 = FactoryGirl.create(:event_choice, :event => @ev2)
  end

  it "should have the checkbox" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => attending_index_path(@registrant), :method => "post" do
      assert_select "input#event_choices_#{@ec1.id}", :name => "event_choices[#{@ec1.id}]"

      assert_select "input[type='checkbox']", 2 do
        assert_select "[checked='checked']", 0
      end
    end
  end

  describe "With existing selections" do
    before(:each) do
      @rc = FactoryGirl.create(:registrant_choice, :value => "1")
      @registrant = @rc.registrant
      @attending = @rc
      @events = [@rc.event_choice.event]

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
        assert_select "input[type='hidden'][name='event_choices[#{@ec1.id}]']"
      end
    end
  end
end
