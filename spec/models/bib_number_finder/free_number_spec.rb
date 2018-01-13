require 'spec_helper'

describe BibNumberFinder::FreeNumber do
  let(:subject) { described_class.new(registrant_type) }

  describe "#next_available_bib_number" do
    context "without being part of a convention_series" do
      context "as a competitor" do
        let(:registrant_type) { "competitor" }

        it "returns number 1 first" do
          expect(subject.next_available_bib_number).to eq(1)
        end
      end

      context "as a noncompetitor" do
        let(:registrant_type) { "noncompetitor" }

        it "returns number 2001 for noncomp" do
          expect(subject.next_available_bib_number).to eq(2001)
        end
      end

      context "as a spectator" do
        let(:registrant_type) { "spectator" }

        it "returns number 2001 for spectator" do
          expect(subject.next_available_bib_number).to eq(2001)
        end
      end

      context "when there is already a number 1" do
        let!(:reg) { FactoryGirl.create(:competitor) }
        let!(:reg2) { FactoryGirl.create(:noncompetitor) }

        context "as a competitor" do
          let(:registrant_type) { "competitor" }

          it "returns number 2" do
            expect(subject.next_available_bib_number).to eq(2)
          end
        end

        context "as a noncompetitor" do
          let(:registrant_type) { "noncompetitor" }

          it "returns number 2002" do
            expect(subject.next_available_bib_number).to eq(2002)
          end
        end
      end
    end

    context "when part of a convention_series" do
      let(:tenant) { Tenant.first }
      let!(:series) { FactoryGirl.create(:convention_series) }
      let!(:series_member) { FactoryGirl.create(:convention_series_member, convention_series: series, tenant: tenant) }

      context "when another convention has a registrant" do
        let!(:other_tenant) { FactoryGirl.create(:tenant, subdomain: "other") }
        before do
          Apartment::Tenant.create "other"
          Apartment::Tenant.switch "other" do
            FactoryGirl.create(:competitor)
          end
        end
        let!(:series_member2) { FactoryGirl.create(:convention_series_member, convention_series: series, tenant: other_tenant) }

        context "as a competitor" do
          let(:registrant_type) { "competitor" }
          it "should choose a number which is unused in all conventions" do
            expect(subject.next_available_bib_number).to eq(2)
          end
        end
      end
    end
  end
end
