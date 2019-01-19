require 'spec_helper'

describe UsaMembershipChecker do
  subject(:subject) { described_class.new(first_name, last_name, birthday) }

  let(:first_name) { "John" }
  let(:last_name) { "Smith" }
  let(:birthday) { Date.new(2000, 1, 1) }
  let(:good_response) do
    [
      {
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
    end
  end

  context "when checking a Suspended member" do
    before do
      allow(subject).to receive(:contacts).and_return(bad_response) # rubocop:disable RSpec/SubjectStub
    end

    it "is not a current member" do
      expect(subject).not_to be_current_member
    end
  end
end
