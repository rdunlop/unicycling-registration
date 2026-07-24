require 'spec_helper'

describe "registrants/build/add_contact_details" do
  let(:wizard_path) { "/" }
  let(:event_config) { EventConfiguration.new } # can be overwritten, per-spec

  before do
    allow(view).to receive(:wizard_path).and_return(wizard_path)
    allow(controller).to receive(:current_user) { FactoryBot.create(:user) }
    assign(:config, event_config)
  end

  describe "medical certificate info page" do
    let(:registrant) { FactoryBot.build(:competitor) }
    let(:medical_info_page) { FactoryBot.create(:page, title: "Medical Info", body: "<h2>Important Medical Info</h2>") }
    let(:event_config) do
      FactoryBot.create(:event_configuration,
                        require_medical_certificate: true,
                        medical_certificate_info_page: medical_info_page)
    end

    before do
      @registrant = registrant
    end

    context "when medical_certificate_info_page is present" do
      it "renders the medical certificate info page" do
        render

        assert_select "fieldset.data_block" do
          assert_select "legend", text: "Mandatory Health Documentation"
        end
        # The page content should be rendered (escaped, not with .html_safe)
        expect(rendered).to include("Medical Info")
      end
    end

    context "when medical_certificate_info_page is not present" do
      let(:event_config) { FactoryBot.create(:event_configuration, require_medical_certificate: true) }

      it "renders the medical certificate section without the info page" do
        render

        assert_select "fieldset.data_block" do
          assert_select "legend", text: "Mandatory Health Documentation"
        end
        # Should not have the page title when not present
        expect(rendered).not_to include("Medical Info")
      end
    end
  end
end
