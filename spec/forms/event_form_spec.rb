# == Schema Information
#
# Table name: events
#
#  id                          :integer          not null, primary key
#  category_id                 :integer
#  position                    :integer
#  created_at                  :datetime
#  updated_at                  :datetime
#  name                        :string(255)
#  visible                     :boolean          default(TRUE), not null
#  accepts_music_uploads       :boolean          default(FALSE), not null
#  artistic                    :boolean          default(FALSE), not null
#  accepts_wheel_size_override :boolean          default(FALSE), not null
#  event_categories_count      :integer          default(0), not null
#  event_choices_count         :integer          default(0), not null
#  best_time_format            :string           default("none"), not null
#
# Indexes
#
#  index_events_category_id                     (category_id)
#  index_events_on_accepts_wheel_size_override  (accepts_wheel_size_override)
#

require 'spec_helper'

describe EventForm do
  let(:category) { FactoryGirl.create(:category) }
  let(:event) { Event.new(category: category) }
  let(:attributes) { FactoryGirl.attributes_for(:event) }

  describe "with normal event elements" do
    it "creates an event" do
      form = described_class.new(event)
      form.assign_attributes(attributes)
      expect(form.save).to be_truthy
    end
  end

  describe "with a cost" do
    let(:attributes_with_cost) { attributes.merge(cost: 10) }

    it "creates an expense_item" do
      form = described_class.new(event)
      form.assign_attributes(attributes_with_cost)
      expect do
        form.save
      end.to change(ExpenseItem, :count).by(1)
    end
  end

  describe "when the event already has a cost" do
    before do
      @form = described_class.new(event)
      @form.assign_attributes(attributes)
      @form.cost = 100
      expect(@form.save).to be_truthy
    end

    describe "when it no longer has a cost" do
      before { @form.cost = "" }
      it { expect { @form.save }.to change(ExpenseItem, :count).by(-1) }
    end

    describe "when it has the same cost" do
      before { @form.cost = "100" }
      it "doesn't change the expense_item" do
        original_expense_item = @form.expense_item
        @form.save
        expect(@form.expense_item).to eq(original_expense_item)
      end
    end

    describe "when it has a different cost" do
      before { @form.cost = "200" }
      it "does change the expense_item" do
        original_expense_item = @form.expense_item
        @form.save
        expect(@form.expense_item).not_to eq(original_expense_item)
      end
    end
  end
end
