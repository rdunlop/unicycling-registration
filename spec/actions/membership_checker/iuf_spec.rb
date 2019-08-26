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
end
