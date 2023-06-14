require 'spec_helper'

describe CategoriesValidator do
  let(:registrant) { FactoryBot.create(:competitor) }

  describe "without any EventCategoryGroupings" do
    it "is valid" do
      expect(registrant.reload).to be_valid
    end
  end

  describe "with a grouping with 2 event_categories" do
    let(:event_1) { FactoryBot.create(:event) }
    let(:event_1_category_1) { FactoryBot.create(:event_category, event: event_1) } # Beginner
    let(:event_1_category_2) { FactoryBot.create(:event_category, event: event_1) } # Advanced
    let(:event_1_category_3) { FactoryBot.create(:event_category, event: event_1) } # Expert

    let(:event_2) { FactoryBot.create(:event) }
    let(:event_2_category_1) { FactoryBot.create(:event_category, event: event_2) } # Beginner
    let(:event_2_category_2) { FactoryBot.create(:event_category, event: event_2) } # Advanced
    let(:event_2_category_3) { FactoryBot.create(:event_category, event: event_2) } # Expert

    let(:event_3) { FactoryBot.create(:event) }
    let(:event_3_category_1) { FactoryBot.create(:event_category, event: event_3) } # Beginner
    let(:event_3_category_2) { FactoryBot.create(:event_category, event: event_3) } # Advanced/expert

    let(:event_category_grouping) { FactoryBot.create(:event_category_grouping) }
    let!(:event_category_grouping_entry_1) { FactoryBot.create(:event_category_grouping_entry, event_category_grouping: event_category_grouping, event_category: event_1_category_1) }
    let!(:event_category_grouping_entry_2) { FactoryBot.create(:event_category_grouping_entry, event_category_grouping: event_category_grouping, event_category: event_2_category_1) }
    let!(:event_category_grouping_entry_3) { FactoryBot.create(:event_category_grouping_entry, event_category_grouping: event_category_grouping, event_category: event_3_category_1) }

    let(:event_category_grouping_2) { FactoryBot.create(:event_category_grouping) }
    let!(:event_category_grouping_2_entry_1) { FactoryBot.create(:event_category_grouping_entry, event_category_grouping: event_category_grouping_2, event_category: event_1_category_2) }
    let!(:event_category_grouping_2_entry_2) { FactoryBot.create(:event_category_grouping_entry, event_category_grouping: event_category_grouping_2, event_category: event_2_category_2) }
    let!(:event_category_grouping_2_entry_3) { FactoryBot.create(:event_category_grouping_entry, event_category_grouping: event_category_grouping_2, event_category: event_3_category_2) }

    let(:event_category_grouping_3) { FactoryBot.create(:event_category_grouping) }
    let!(:event_category_grouping_3_entry_1) { FactoryBot.create(:event_category_grouping_entry, event_category_grouping: event_category_grouping_3, event_category: event_1_category_3) }
    let!(:event_category_grouping_3_entry_2) { FactoryBot.create(:event_category_grouping_entry, event_category_grouping: event_category_grouping_3, event_category: event_2_category_3) }
    let!(:event_category_grouping_3_entry_3) { FactoryBot.create(:event_category_grouping_entry, event_category_grouping: event_category_grouping_3, event_category: event_3_category_2) }

    context "with a selection of this entry" do
      let!(:registrant_event_sign_up) { FactoryBot.create(:registrant_event_sign_up, registrant: registrant, event: event_1, event_category: event_1_category_1) }

      it "is valid" do
        expect(registrant.reload).to be_valid
      end
    end

    context "having chosen a different event_category for an entry in a group" do
      let!(:registrant_event_sign_up1) { FactoryBot.create(:registrant_event_sign_up, registrant: registrant, event: event_1, event_category: event_1_category_1) }
      let!(:registrant_event_sign_up2) { FactoryBot.create(:registrant_event_sign_up, registrant: registrant, event: event_2, event_category: event_2_category_2) }

      it "is not valid" do
        expect(registrant.reload).not_to be_valid
      end
    end

    context "having chosen an Adv,Expert" do
      let!(:registrant_event_sign_up1) { FactoryBot.create(:registrant_event_sign_up, registrant: registrant, event: event_1, event_category: event_1_category_2) }
      let!(:registrant_event_sign_up2) { FactoryBot.create(:registrant_event_sign_up, registrant: registrant, event: event_2, event_category: event_2_category_3) }

      it "is not valid" do
        expect(registrant.reload).not_to be_valid
      end
    end

    context "having chosen an Adv,Expert, Advanced/Expert" do
      let!(:registrant_event_sign_up1) { FactoryBot.create(:registrant_event_sign_up, registrant: registrant, event: event_1, event_category: event_1_category_2) }
      let!(:registrant_event_sign_up2) { FactoryBot.create(:registrant_event_sign_up, registrant: registrant, event: event_2, event_category: event_2_category_3) }
      let!(:registrant_event_sign_up3) { FactoryBot.create(:registrant_event_sign_up, registrant: registrant, event: event_3, event_category: event_3_category_2) }

      it "is not valid" do
        expect(registrant.reload).not_to be_valid
      end
    end

    context "having chosen an Adv,Adv, Advanced/Expert" do
      let!(:registrant_event_sign_up1) { FactoryBot.create(:registrant_event_sign_up, registrant: registrant, event: event_1, event_category: event_1_category_2) }
      let!(:registrant_event_sign_up2) { FactoryBot.create(:registrant_event_sign_up, registrant: registrant, event: event_2, event_category: event_2_category_2) }
      let!(:registrant_event_sign_up3) { FactoryBot.create(:registrant_event_sign_up, registrant: registrant, event: event_3, event_category: event_3_category_2) }

      it "is valid" do
        expect(registrant.reload).to be_valid
      end
    end

    context "having chosen an Exp,Exp, Advanced/Expert" do
      let!(:registrant_event_sign_up1) { FactoryBot.create(:registrant_event_sign_up, registrant: registrant, event: event_1, event_category: event_1_category_3) }
      let!(:registrant_event_sign_up2) { FactoryBot.create(:registrant_event_sign_up, registrant: registrant, event: event_2, event_category: event_2_category_3) }
      let!(:registrant_event_sign_up3) { FactoryBot.create(:registrant_event_sign_up, registrant: registrant, event: event_3, event_category: event_3_category_2) }

      it "is valid" do
        expect(registrant.reload).to be_valid
      end
    end
  end
end
