require 'spec_helper'

describe EventCategoryGroupingEntry do
  context "when created with a event category and no group" do
    let(:event_category) { FactoryBot.create(:event_category) }

    it "creates a group" do
      entry = described_class.new(event_category_id: event_category.id)
      expect(entry.save).to be_truthy
      expect(EventCategoryGrouping.count).to eq(1)
    end
  end

  context "when deleting an entry" do
    let!(:entry) { FactoryBot.create(:event_category_grouping_entry) }

    it "destroys the grouping" do
      expect do
        entry.destroy
      end.to change(EventCategoryGrouping, :count).by(-1)
    end

    context "when there are multiple entries for the same grouping" do
      let!(:entry2) { FactoryBot.create(:event_category_grouping_entry, event_category_grouping: entry.event_category_grouping) }
      it "does not destroy the grouping" do
        expect do
          entry.destroy
        end.not_to change(EventCategoryGrouping, :count)
      end
    end
  end
end
