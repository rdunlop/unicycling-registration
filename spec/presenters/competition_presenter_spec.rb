require 'spec_helper'

describe CompetitionPresenter do
  let(:competition) { FactoryGirl.build_stubbed(:competition) }
  let(:presenter) { described_class.new(competition) }

  describe "#status" do
    describe "with no competitors" do
      it "has status and status_code" do
        expect(presenter.status_code).to eq("no_competitors")
        expect(presenter.status).to eq("No Competitors Defined")
      end
    end
    describe "with competitors" do
      before { FactoryGirl.create(:event_competitor, competition: competition) }

      it "has status and status_code" do
        expect(presenter.status_code).to eq("no_results")
        expect(presenter.status).to eq("No Results Found")
      end

      describe "with results" do
        before { allow(competition).to receive(:num_results).and_return 10 }

        it "has status and status_code" do
          expect(presenter.status_code).to eq("incomplete")
          expect(presenter.status).to eq("Results Incomplete")
        end

        describe "with a locked competition" do
          before { allow(competition).to receive(:locked?).and_return true }

          it "has status and status_code" do
            expect(presenter.status_code).to eq("complete")
            expect(presenter.status).to eq("Results Completed (unpublished)")
          end

          describe "with a published competition" do
            before do
              allow(competition).to receive(:published?).and_return true
              allow(competition).to receive(:awarded?).and_return false
            end

            it "has status and status_code" do
              expect(presenter.status_code).to eq("published")
              expect(presenter.status).to eq("Results Published")
            end

            describe "with an awarded competition" do
              before do
                allow(competition).to receive(:awarded?).and_return true
              end

              it "has status and status_code" do
                expect(presenter.status_code).to eq("awarded")
                expect(presenter.status).to eq("Complete (Awarded)")
              end
            end
          end
        end
      end
    end
  end
end
