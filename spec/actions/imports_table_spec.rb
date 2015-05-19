require 'spec_helper'

describe ImportsTable do
  context "for a user import" do
    let(:subject) { described_class.new(User) }

    context "with a user hash" do
      let(:hash) do
        {
          email: "robin@dunlopweb.com",
          password: "soething",
          confirmed_at: "2015-01-01",
          name: "Robin"
        }
      end

      it "creates a user object" do
        expect(User.count).to eq(0)
        expect(subject.import(hash)).to be_truthy

        expect(User.count).to eq(1)
        expect(User.last.name).to eq("Robin")
      end
    end
  end

  describe "with a lookup function" do
    let!(:user) { FactoryGirl.create :user }
    let(:hash) do
      {
        lookup_user_id_by_email: user.email,
        id: 12,
        first_name: "Robin",
        last_name: "Dunlop",
        gender: "Male",
        birthday: "1930-01-01",
        status: "blank",
        registrant_type: "competitor"
      }
    end

    it "looks up the user by e-mail" do
      importer = described_class.new(Registrant)

      expect(Registrant.count).to be(0)
      expect(importer.import(hash)).to be_truthy
      expect(Registrant.count).to be(1)
    end

    it "finds user when the email was uppercase" do
      importer = described_class.new(Registrant)
      new_hash = hash
      new_hash[:lookup_user_id_by_email] = user.email.upcase

      expect(Registrant.count).to be(0)
      expect(importer.import(new_hash)).to be_truthy
      expect(Registrant.count).to be(1)
    end
  end
end

