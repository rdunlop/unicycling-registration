require 'spec_helper'

describe ChoicesValidator do
  let(:registrant) { FactoryGirl.create(:competitor) }

  describe "with a boolean choice event" do
    let(:event) { FactoryGirl.create(:event) }
    let(:event_category) { event.event_categories.first }

    let!(:resu) do
      FactoryGirl.create(:registrant_event_sign_up, registrant: registrant, event: event, event_category: event_category, signed_up: true)
    end

    it "can describe the event" do
      expect(registrant.describe_event(event)).to eq(event.name)
    end

    context "with a single boolean event choice" do
      let(:boolean_choice) { FactoryGirl.create(:event_choice, event: event) }

      it "can select the boolean choice" do
        FactoryGirl.create(:registrant_choice, registrant: registrant, event_choice: boolean_choice, value: "1")
        expect(registrant).to be_valid
      end

      it "can be not signed up, with a boolean event_choice" do
        FactoryGirl.create(:registrant_choice, registrant: registrant, event_choice: boolean_choice, value: "0")
        resu.update_attribute(:signed_up, false)

        expect(registrant).to be_valid
      end
    end

    describe "and a text field" do
      before(:each) do
        @ec2 = FactoryGirl.create(:event_choice, event: event, label: "Team", cell_type: "text")
        @rc2 = FactoryGirl.create(:registrant_choice, registrant: registrant, event_choice: @ec2, value: "My Team")
      end
      it "can describe the event" do
        expect(registrant.describe_event(event)).to eq("#{event.name} - #{@ec2.label}: #{@rc2.value}")
      end
    end
    # DISABLED because 'multiple' is a deprecated type
    # describe "and a select field" do
    #   before(:each) do
    #     @ec2 = FactoryGirl.create(:event_choice, event: event, label: "Category", cell_type: "multiple")
    #     @rc2 = FactoryGirl.create(:registrant_choice, registrant: registrant, event_choice: @ec2, value: "Advanced")
    #   end
    #   it "can describe the event" do
    #     expect(registrant.describe_event(event)).to eq("#{event.name} - #{@ec2.label}: #{@rc2.value}")
    #   end
    #   it "doesn't break without a registrant choice" do
    #     @rc2.destroy
    #     expect(registrant.describe_event(event)).to eq("#{event.name}")
    #   end
    # end
  end

  describe "with a single event_choices for an event" do
    before(:each) do
      @ev = FactoryGirl.create(:event)
      @ec1 = @ev.event_categories.first
    end

    it "is valid without having selection" do
      expect(registrant.valid?).to eq(true)
    end
    it "is valid when having checked off this event" do
      FactoryGirl.create(:registrant_event_sign_up, event: @ev, event_category: @ec1, signed_up: true, registrant: registrant)
      expect(registrant.valid?).to eq(true)
    end
    describe "with a second (boolean) event_choice for an event" do
      before(:each) do
        @ec2 = FactoryGirl.create(:event_choice, event: @ev)
      end
      it "should be valid if we only check off the primary_choice" do
        FactoryGirl.create(:registrant_event_sign_up, event: @ev, event_category: @ec1, signed_up: true, registrant: registrant)
        registrant.reload
        expect(registrant.valid?).to eq(true)
      end
      it "should be valid if we check off both event_choices" do
        registrant.reload
        expect(registrant.valid?).to eq(true)
        FactoryGirl.create(:registrant_event_sign_up, event: @ev, event_category: @ec1, signed_up: true, registrant: registrant)
        FactoryGirl.create(:registrant_choice, event_choice: @ec2, value: "1", registrant: registrant)
        registrant.reload
        expect(registrant.valid?).to eq(true)
      end
      it "should be invalid if we only check off the second_choice" do
        FactoryGirl.create(:registrant_choice, event_choice: @ec2, value: "1", registrant: registrant)
        FactoryGirl.create(:registrant_event_sign_up, event: @ev, event_category: @ec1, signed_up: false, registrant: registrant)
        registrant.reload
        expect(registrant.valid?).to eq(false)
      end
      it "should describe the event" do
        FactoryGirl.create(:registrant_choice, event_choice: @ec2, value: "1", registrant: registrant)
        expect(registrant.describe_event(@ev)).to eq("#{@ev.name} - #{@ec2.label}: yes")
      end

      describe "with a text_field optional_if_event_choice to the boolean" do
        before(:each) do
          FactoryGirl.create(:registrant_event_sign_up, event: @ev, event_category: @ec1, signed_up: true, registrant: registrant)
          @ec3 = FactoryGirl.create(:event_choice, event: @ev, cell_type: "text", optional_if_event_choice: @ec2)
          registrant.reload
        end

        it "allows the registrant to NOT specify a value for the text field if the checkbox is selected" do
          FactoryGirl.create(:registrant_choice, event_choice: @ec2, value: "1", registrant: registrant)
          FactoryGirl.create(:registrant_choice, event_choice: @ec3, value: "", registrant: registrant)
          registrant.reload
          expect(registrant.valid?).to eq(true)
        end

        it "REQUIRES the registrant specify a value for the text field if the checkbox is NOT selected" do
          FactoryGirl.create(:registrant_choice, event_choice: @ec2, value: "0", registrant: registrant)
          FactoryGirl.create(:registrant_choice, event_choice: @ec3, value: "", registrant: registrant)
          registrant.reload
          expect(registrant.valid?).to eq(false)
        end
      end
      describe "with a text_field required_if_event_choice" do
        before(:each) do
          FactoryGirl.create(:registrant_event_sign_up, event: @ev, event_category: @ec1, signed_up: true, registrant: registrant)
          @ec3 = FactoryGirl.create(:event_choice, event: @ev, cell_type: "text", required_if_event_choice: @ec2)
          registrant.reload
        end

        it "requires the registrant to specify a value for the text field if the checkbox is selected" do
          FactoryGirl.create(:registrant_choice, event_choice: @ec2, value: "1", registrant: registrant)
          rc = FactoryGirl.create(:registrant_choice, event_choice: @ec3, value: "", registrant: registrant)
          registrant.reload
          expect(registrant.valid?).to eq(false)
          rc.value = "hello"
          rc.save
          registrant.reload
          expect(registrant.valid?).to eq(true)
        end

        it "allows the registrant to NOT specify a value for the text field if the checkbox is NOT selected" do
          FactoryGirl.create(:registrant_choice, event_choice: @ec2, value: "0", registrant: registrant)
          FactoryGirl.create(:registrant_choice, event_choice: @ec3, value: "", registrant: registrant)
          registrant.reload
          expect(registrant.valid?).to eq(true)
        end
      end
    end
    describe "with a second event_choice (text-style) for an event" do
      before(:each) do
        @ec2 = FactoryGirl.create(:event_choice, event: @ev, cell_type: "text")
      end
      it "should be invalid if we only check off the primary_choice" do
        FactoryGirl.create(:registrant_event_sign_up, event: @ev, event_category: @ec1, signed_up: true, registrant: registrant)
        registrant.reload
        expect(registrant.valid?).to eq(false)
      end
      it "should be valid if we fill in both event_choices" do
        FactoryGirl.create(:registrant_event_sign_up, event: @ev, event_category: @ec1, signed_up: true, registrant: registrant)
        FactoryGirl.create(:registrant_choice, event_choice: @ec2, value: "hello there", registrant: registrant)
        registrant.reload
        expect(registrant.valid?).to eq(true)
      end
      it "should be valid if we don't choose the event, and we don't fill in the event_choice" do
        FactoryGirl.create(:registrant_event_sign_up, event: @ev, event_category: @ec1, signed_up: false, registrant: registrant)
        FactoryGirl.create(:registrant_choice, event_choice: @ec2, value: "", registrant: registrant)
        registrant.reload
        expect(registrant.valid?).to eq(true)
      end
      it "should be invalid if we fill in only the second_choice" do
        FactoryGirl.create(:registrant_choice, event_choice: @ec2, value: "goodbye", registrant: registrant)
        FactoryGirl.create(:registrant_event_sign_up, event: @ev, event_category: @ec1, signed_up: false, registrant: registrant)
        registrant.reload
        expect(registrant.valid?).to eq(false)
      end
      describe "if the second choices is optional" do
        before(:each) do
          @ec2.optional = true
          @ec2.save!
          registrant.reload
        end
        it "should allow empty registarnt_choice" do
          FactoryGirl.create(:registrant_event_sign_up, event: @ev, event_category: @ec1, signed_up: true, registrant: registrant)
          FactoryGirl.create(:registrant_choice, event_choice: @ec2, value: "", registrant: registrant)
          registrant.reload
          expect(registrant.valid?).to eq(true)
        end
      end
    end
  end
  describe "when saving a registrant with multiple (invalid) registrant_choice" do
    before(:each) do
      @ei = FactoryGirl.create(:expense_item, maximum_available: 1)
    end
    it "cannot save with 2 registrante_expense_items when only 1 should be possible" do
      @ei1 = registrant.registrant_expense_items.build(expense_item_id: @ei.id)
      @ei2 = registrant.registrant_expense_items.build(expense_item_id: @ei.id)
      expect(registrant.valid?).to eq(false)
    end
  end
end
