require 'spec_helper'

describe CategoryHelper do
  let(:category) { FactoryGirl.create :category }

  context "with an info_url" do
    let(:category) { FactoryGirl.create :category, info_url: "http://www.google.com" }

    it "returns the url as the additional_information_url" do
      expect(helper.additional_information_url(category)).to eq("http://www.google.com")
    end
  end

  context "with an info_page specified" do
    let(:page) { FactoryGirl.create :page }
    let(:category) { FactoryGirl.create :category, info_page: page }

    it "returns the info_page url when the info_url is blank" do
      category.update_attribute(:info_url, "")
      expect(helper.additional_information_url(category)).to eq("http://test.host/en/pages/#{page.slug}?framed=true")
    end

    it "returns the info_page url as the additional_information_url" do
      expect(helper.additional_information_url(category)).to eq("http://test.host/en/pages/#{page.slug}?framed=true")
    end

    context "with a different locale" do
      it "has the correct prefix" do
        expect(helper.additional_information_url(category, :fr)).to eq("http://test.host/fr/pages/#{page.slug}?framed=true")
      end
    end
  end
end
