require 'spec_helper'

describe EventsExporter do
  before do
    @ev = FactoryGirl.create(:event)
  end

  let(:base_headers) { ["ID", "First Name", "Last Name", "Birthday", "Age", "Gender", "Club"]}
  let(:exporter) { described_class.new }

  it "sets the headers" do
    headers = exporter.headers
    expect(headers).to eq(base_headers << @ev.event_categories.first.to_s)
  end

  describe "with a registrant" do
    let!(:reg) { FactoryGirl.create(:competitor) }
    it "sets the rows" do
      data = exporter.rows
      expect(data[0]).to eq([reg.bib_number, reg.first_name, reg.last_name, reg.birthday, reg.age, reg.gender, reg.club, nil])
    end

    describe "with a registration choice for the event" do
      before(:each) do
        @ecat = @ev.event_categories.first
        @rc = FactoryGirl.create(:registrant_event_sign_up, registrant: reg, event_category: @ecat, event: @ev, signed_up: true)
      end

      it "has a value in the event-signed-up target column" do
        data = exporter.rows
        expect(data[0][base_headers.count]).to eq(true)
      end
    end
  end
end
