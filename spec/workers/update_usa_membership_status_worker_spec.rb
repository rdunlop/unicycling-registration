require 'spec_helper'

describe UpdateUsaMembershipStatusWorker do
  let(:membership_number) { 123 }
  let(:last_name) { "Smith" }
  let(:server) { "example.com" }
  let(:endpoint) { "/wp-content/themes/twentytwelve-child-unimember/naucc.php" }
  let(:apikey) { "abc" }

  subject(:worker) { described_class.new }
  before do
    allow(subject).to receive(:server).and_return(server)
    allow(subject).to receive(:endpoint).and_return(endpoint)
    allow(subject).to receive(:apikey).and_return(apikey)
    allow(subject).to receive(:event_start_date).and_return(DateTime.new(2016, 7, 9))
  end

  describe "#build_url" do
    let(:url) { subject.build_url(membership_number, last_name).to_s }

    it "includes the API key" do
      expect(url).to include("apikey=#{apikey}")
    end

    it "includes the membership number" do
      expect(url).to include("membernum=#{membership_number}")
    end

    it "includes the last name" do
      expect(url).to include("lastname=#{last_name}")
    end

    it "starts with the server" do
      expect(url).to start_with("https://example.com/wp-content")
    end

    it "includes the target date" do
      expect(url).to include("strdatetocheck=2016-07-09")
    end

    describe "special cases" do
      describe "multiple words" do
        let(:last_name) { "van der Velden" }
        it { expect(url).to include("lastname=van+der+Velden") }
      end

      describe "apostrophes" do
        let(:last_name) { "O'Brien" }
        it { expect(url).to include("lastname=O%27Brien") }
      end
    end
  end

  describe "#call_api" do
  end

  describe "#store_result" do
    let(:contact_detail) { FactoryGirl.create(:contact_detail) }

    before do
      subject.process_response(contact_detail, JSON.parse(response_hash.to_json))
    end

    describe "with a success" do
      let(:response_hash) do
        {
          success: true,
          message: "You are a member"
        }
      end

      it "stores a success and message" do
        expect(contact_detail.usa_member_number_valid?).to be_truthy
        expect(contact_detail.usa_member_number_status).to eq("You are a member")
      end
    end

    describe "with a failure" do
      let(:response_hash) do
        {
          success: false,
          message: "Your Membership has expired"
        }
      end

      it "stores failure and a message" do
        expect(contact_detail.usa_member_number_valid?).to be_falsy
        expect(contact_detail.usa_member_number_status).to eq("Your Membership has expired")
      end
    end
  end
end
