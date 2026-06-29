require 'spec_helper'

describe MembershipChecker::Iuf do
  subject(:subject) do
    described_class.new(
      first_name: first_name,
      last_name: last_name,
      birthdate: birthday,
      manual_member_number: usa_member_number,
      system_member_number: iuf_member_number
    )
  end

  let(:first_name) { "John" }
  let(:last_name) { "Smith" }
  let(:birthday) { Date.new(2000, 1, 1) }
  let(:usa_member_number) { nil }
  let(:iuf_member_number) { nil }
  let(:good_response) do
    {
      "member" => true,
      "iuf_member_id" => "12345"
    }
  end
  let(:bad_response) do
    {
      "member" => false
    }
  end

  context "when checking good member" do
    before do
      allow(subject).to receive(:status).and_return(good_response) # rubocop:disable RSpec/SubjectStub
    end

    it "is a current member" do
      expect(subject).to be_current_member
      expect(subject.current_system_id).to eq("12345")
    end
  end

  context "when checking a missing member" do
    before do
      allow(subject).to receive(:status).and_return(bad_response) # rubocop:disable RSpec/SubjectStub
    end

    it "is not a current member" do
      expect(subject).not_to be_current_member
      expect(subject.current_system_id).to be_nil
    end
  end

  describe "#status" do
    # Regression: previously used Faraday (removed gem), which raised
    # NameError: uninitialized constant MembershipChecker::Iuf::Faraday.
    # Now uses Net::HTTP from stdlib.
    let(:http_response) do
      instance_double(Net::HTTPSuccess, is_a?: true, body: good_response.to_json).tap do |r|
        allow(r).to receive(:is_a?).with(Net::HTTPSuccess).and_return(true)
      end
    end

    before do
      allow(Rails.configuration).to receive(:iuf_membership_api_url).and_return("https://example.com/api")
      allow(Net::HTTP).to receive(:post_form).and_return(http_response)
      EventConfiguration.singleton.update(start_date: Date.new(2024, 7, 12))
    end

    it "returns the parsed response without raising NameError" do
      expect { subject.status }.not_to raise_error
      expect(subject.status).to eq(good_response)
    end
  end

  context "with an event configuration start date" do
    before do
      EventConfiguration.singleton.update(start_date: Date.new(2024, 7, 12))
    end

    it "has the correct request params" do
      expect(subject.request_params).to eq(
        "first_name" => "John",
        "last_name" => "Smith",
        "birthdate" => "2000-01-01",
        "eventdate" => "2024-07-24"
      )
    end
  end
end
