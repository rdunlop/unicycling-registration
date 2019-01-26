require 'spec_helper'

describe UsaMembershipChecker do
  subject(:subject) do
    described_class.new(
      first_name: first_name,
      last_name: last_name,
      birthdate: birthday,
      manual_member_number: usa_member_number,
      wildapricot_member_number: wildapricot_member_number
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
      expect(subject.current_wildapricot_id).to eq("12345")
    end
  end

  context "when checking a Suspended member" do
    before do
      allow(subject).to receive(:contacts).and_return(bad_response) # rubocop:disable RSpec/SubjectStub
    end

    it "is not a current member" do
      expect(subject).not_to be_current_member
      expect(subject.current_wildapricot_id).to be_nil
    end
  end
end
