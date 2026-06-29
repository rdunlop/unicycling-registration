require 'spec_helper'

describe MembershipChecker::Usa do
  subject(:subject) do
    described_class.new(
      first_name: first_name,
      last_name: last_name,
      birthdate: birthday,
      manual_member_number: usa_member_number,
      system_member_number: wildapricot_member_number
    )
  end

  let(:first_name) { "John" }
  let(:last_name) { "Smith" }
  let(:birthday) { Date.new(2000, 1, 1) }
  let(:usa_member_number) { nil }
  let(:wildapricot_member_number) { nil }
  let(:good_response) do
    [
      {
        "Id" => "12345",
        "FirstName" => "John",
        "LastName" => "Smith",
        "MembershipEnabled" => true,
        "Status" => "Active",
        "FieldValues" => [
          {
            "FieldName" => "Suspended member",
            "Value" => false,
            "SystemCode" => "IsSuspendedMember"
          }
        ]
      }
    ]
  end
  let(:bad_response) do
    [
      {
        "FirstName" => "Jane",
        "LastName" => "Smith",
        "MembershipEnabled" => false,
        "Status" => "Lapsed",
        "FieldValues" => [
          {
            "FieldName" => "Suspended member",
            "Value" => true,
            "SystemCode" => "IsSuspendedMember"
          }
        ]
      }
    ]
  end

  context "when checking good member" do
    before do
      allow(subject).to receive(:contacts).and_return(good_response) # rubocop:disable RSpec/SubjectStub
    end

    it "is a current member" do
      expect(subject).to be_current_member
      expect(subject.current_system_id).to eq("12345")
    end
  end

  context "when checking a Suspended member" do
    before do
      allow(subject).to receive(:contacts).and_return(bad_response) # rubocop:disable RSpec/SubjectStub
    end

    it "is not a current member" do
      expect(subject).not_to be_current_member
      expect(subject.current_system_id).to be_nil
    end
  end

  # These two describe blocks test the HTTP layer directly.
  # The `contacts` method short-circuits with `return [] if Rails.env.test?`
  # so `token` and `search_contacts` are never reached via the normal flow in
  # tests — meaning a missing/broken HTTP library would not be caught.
  describe "#token" do
    let(:http) { instance_double(Net::HTTP) }
    let(:token_response) do
      instance_double(Net::HTTPSuccess).tap do |r|
        allow(r).to receive(:is_a?).with(Net::HTTPSuccess).and_return(true)
        allow(r).to receive(:body).and_return({ "access_token" => "fake-token" }.to_json)
      end
    end

    before do
      allow(Rails.configuration).to receive(:usa_wildapricot_api_key).and_return("test-key")
      allow(Net::HTTP).to receive(:start).and_yield(http)
      allow(http).to receive(:request).and_return(token_response)
    end

    it "returns an access token without raising NameError" do
      expect { subject.send(:token) }.not_to raise_error
      expect(subject.send(:token)).to eq("fake-token")
    end
  end

  describe "#search_contacts" do
    let(:http) { instance_double(Net::HTTP) }
    let(:contacts_response) do
      instance_double(Net::HTTPSuccess).tap do |r|
        allow(r).to receive(:is_a?).with(Net::HTTPSuccess).and_return(true)
        allow(r).to receive(:body).and_return({ "Contacts" => good_response }.to_json)
      end
    end

    before do
      allow(Rails.configuration).to receive(:usa_wildapricot_account_id).and_return("456")
      allow(subject).to receive(:token).and_return("fake-token") # rubocop:disable RSpec/SubjectStub
      allow(Net::HTTP).to receive(:start).and_yield(http)
      allow(http).to receive(:request).and_return(contacts_response)
    end

    it "returns contacts without raising NameError" do
      expect { subject.send(:search_contacts, "'ID' eq '123'") }.not_to raise_error
      expect(subject.send(:search_contacts, "'ID' eq '123'")).to eq(good_response)
    end
  end
end
