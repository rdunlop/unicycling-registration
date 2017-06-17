require 'spec_helper'

describe RegistrationHelper do
  let(:user) { FactoryGirl.create(:user) }
  def create_registrant_in_previous_convention(subdomain:, user_attributes:)
    FactoryGirl.create(:tenant, subdomain: subdomain)
    FactoryGirl.create(:user_convention, user: user, subdomain: subdomain)
    Apartment::Tenant.create(subdomain)
    reg = nil
    Apartment::Tenant.switch(subdomain) do
      reg = FactoryGirl.create(:competitor, user: user, **user_attributes)
    end

    reg
  end

  shared_examples_for "return an empty array" do
    it "return an empty array" do
      expect(helper.previous_registrants_for(user)).to eq([])
    end
  end

  describe "previous_registrants_for" do
    it_should_behave_like "return an empty array"

    context "with a registrant" do
      let!(:registrant) { FactoryGirl.create(:competitor, user: user) }

      it_should_behave_like "return an empty array"
    end

    context "with a registrant from a previous convention" do
      before do
        @old_registrant = create_registrant_in_previous_convention(
          subdomain: "other", user_attributes: { first_name: "Bob", last_name: "Smith" }
        )
      end

      it "returns the registrants with subdomain keys" do
        expect(helper.previous_registrants_for(user)).to eq(
          [
            ["other - Bob Smith", RegistrantCopier.build_key("other", @old_registrant.id)]
          ]
        )
      end

      context "with a 2nd, older convention" do
        before do
          travel(- 2.months) do
            @older_registrant = create_registrant_in_previous_convention(
              subdomain: "older", user_attributes: { first_name: "Robert", last_name: "Smith" }
            )
          end
        end

        it "returns the registrants in reverse calendar order" do
          expect(helper.previous_registrants_for(user)).to eq(
            [
              ["other - Bob Smith", RegistrantCopier.build_key("other", @old_registrant.id)],
              ["older - Robert Smith", RegistrantCopier.build_key("older", @older_registrant.id)]
            ]
          )
        end
      end
    end

    context "with an incomplete registrant in a previous convention" do
      before do
        @old_registrant = create_registrant_in_previous_convention(
          subdomain: "other", user_attributes: { first_name: "Bob", last_name: "Smith", status: "events" }
        )
      end

      it_should_behave_like "return an empty array"
    end

    context "with a deleted registrant in a previous convention" do
      before do
        @old_registrant = create_registrant_in_previous_convention(
          subdomain: "other", user_attributes: { first_name: "Bob", last_name: "Smith", deleted: true}
        )
      end

      it_should_behave_like "return an empty array"
    end
  end
end
