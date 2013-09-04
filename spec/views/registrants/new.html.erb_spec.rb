require 'spec_helper'

describe "registrants/new" do
  before(:each) do
    @comp_exp = FactoryGirl.create(:expense_item, :cost => 100)
    @noncomp_exp = FactoryGirl.create(:expense_item, :cost => 50)
    @registration_period = FactoryGirl.create(:registration_period, 
                                              :start_date => Date.new(2012, 01, 10),
                                              :end_date => Date.new(2012, 02, 11),
                                              :competitor_expense_item => @comp_exp,
                                              :noncompetitor_expense_item => @noncomp_exp)
    @ability = Object.new
    @ability.extend(CanCan::Ability)
    controller.stub(:current_ability) { @ability }
  end
  describe "Competitor" do
    before(:each) do
      @registrant = FactoryGirl.build(:competitor)
      @categories = [] # none are _needed_
    end

    it "renders new registrant form" do
      render

      # Run the generator again with the --webrat flag if you want to use webrat matchers
      assert_select "form", :action => registrants_path, :method => "post" do
        assert_select "input#registrant_first_name", :name => "registrant[first_name]"
        assert_select "input#registrant_middle_initial", :name => "registrant[middle_initial]"
        assert_select "input#registrant_last_name", :name => "registrant[last_name]"
        assert_select "input#registrant_gender_male", :name => "registrant[gender]"
        assert_select "input#registrant_competitor", :name => "registrant[competitor]"
      end
    end
    it "displays the 'Continue' button" do
      render
      assert_select "input[value='Continue (Expenses...)']", 1
    end
  end

  describe "as non-competitor" do
    before(:each) do
      @registrant = FactoryGirl.build(:noncompetitor)
    end
    it "displays the words Non-Competitor" do
      render
      assert_select "h2", :text => "Non-Competitor"
    end
    it "displays the 'Save Registration' button" do
      render
      assert_select "input[value='Continue (Expenses...)']", 1
    end
  end

  describe "the events lists" do
    before(:each) do
      @registrant = FactoryGirl.build(:competitor)
      @registration_period = FactoryGirl.create(:registration_period, 
                                                :start_date => Date.new(2012, 01, 10),
                                                :end_date => Date.new(2012, 02, 11))
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
        assert_select "form", :action => registrants_path, :method => "post" do
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
          @rc = FactoryGirl.create(:registrant_choice, :value => "1", :event_choice => @ec1)
          @registrant = @rc.registrant
          @registrant.reload
          @attending = @rc
          @categories = [@rc.event_choice.event.category]

          @ec1 = @rc.event_choice
        end

        it "displays the checkbox as checked off" do
          render

          assert_select "form", :action => registrant_path(@registrant), :method => "put" do
            assert_select "div[id='tabs']" do
              assert_select "input[type='checkbox']", 2 do
                assert_select "[checked='checked']", 1
              end
            end
            assert_select "label", :text => @ec1.event.to_s
          end
        end
        it "renders as not-checked-off if value is '0'" do
          @rc.value = "0"
          @rc.save
          render

          assert_select "form", :action => registrant_path(@registrant), :method => "put" do
            assert_select "div[id='tabs']" do
              assert_select "input[type='checkbox']", 2 do
                assert_select "[checked='checked']", 0
              end
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
      end
      describe "without a choice selected" do
        before(:each) do
          rc = @registrant.registrant_choices.build
          rc.event_choice_id = @ec1.id
        end
        it "should have the text input" do
          render

          assert_select "form", :action => registrants_path, :method => "post" do
            assert_select "input#registrant_registrant_choices_attributes_0_event_choice_id", :name => "registrant[registrant_choices_attributes][0][event_choice_id]" do
              assert_select "input[value='#{@ec1.id}']"
            end
            assert_select "input#registrant_registrant_choices_attributes_0_value", :name => "registrant[registrant_choices_attributes][0][value]" do
              assert_select "input[type='text']", 1
            end
          end
        end
      end
      describe "for already present choice" do
        before(:each) do
          rc = @registrant.registrant_choices.build
          rc.event_choice_id = @ec1.id
          rc.value = "Hello"
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

        assert_select "#tabs" do
          assert_select "select", 1
        end
      end

      it "has the 3+1(blank) values as options" do
        render

        assert_select "#tabs" do
          assert_select "select" do
            assert_select "option", 4
            assert_select "option[value='one']"
            assert_select "option[value='two']"
            assert_select "option[value='three']"
          end
        end
      end
    end
  end

  describe "Non competitor" do
    before(:each) do
      @registrant = FactoryGirl.create(:noncompetitor)
      @categories = []
    end
    it "renders new contact_info form" do
      render

      # Run the generator again with the --webrat flag if you want to use webrat matchers
      assert_select "form", :action => registrant_path(@registrant), :method => "put" do
        assert_select "input#registrant_state", :name => "registrant[state]"
        assert_select "input#registrant_address", :name => "registrant[address]"
        assert_select "select#registrant_country_residence", :name => "registrant[country_residence]"
        assert_select "input#registrant_state", :name => "registrant[state]"
        assert_select "input#registrant_city", :name => "registrant[city]"
        assert_select "input#registrant_zip", :name => "registrant[zip]"
        assert_select "input#registrant_phone", :name => "registrant[phone]"
        assert_select "input#registrant_mobile", :name => "registrant[mobile]"
        assert_select "input#registrant_email", :name => "registrant[email]"
        assert_select "input#registrant_club", :name => "registrant[club]"
        assert_select "input#registrant_club_contact", :name => "registrant[club_contact]"
        assert_select "input#registrant_usa_member_number", :name => "registrant[usa_member_number]"
        assert_select "input#registrant_emergency_name", :name => "registrant[emergency_name]"
        assert_select "input#registrant_emergency_relationship", :name => "registrant[emergency_relationship]"
        assert_select "input#registrant_emergency_attending", :name => "registrant[emergency_attending]"
        assert_select "input#registrant_emergency_primary_phone", :name => "registrant[emergency_primary_phone]"
        assert_select "input#registrant_emergency_other_phone", :name => "registrant[emergency_other_phone]"
        assert_select "input#registrant_responsible_adult_name", :name => "registrant[responsible_adult_name]"
        assert_select "input#registrant_responsible_adult_phone", :name => "registrant[responsible_adult_phone]"
      end
    end
  end

  describe "Competitor" do
    before(:each) do
      @registrant = FactoryGirl.create(:competitor)
      @categories = [] # none are _needed_
    end
    it "renders dates in nice formats" do
      render
      # Run the generator again with the --webrat flag if you want to use webrat matchers
      rendered.should match(/Jan 10, 2012/)
      rendered.should match(/Feb 11, 2012/)
    end
    it "lists competitor costs" do
      render
      rendered.should match(/100/)
    end
  end

  describe "as non-competitor" do
    before(:each) do
      @registrant = FactoryGirl.create(:noncompetitor)
    end
    it "displays the registration_period for non-competitors" do
      render
      rendered.should match(/50/)
    end
  end
end
