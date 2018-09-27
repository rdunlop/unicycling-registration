# == Schema Information
#
# Table name: pages
#
#  id             :integer          not null, primary key
#  slug           :string           not null
#  created_at     :datetime
#  updated_at     :datetime
#  position       :integer
#  parent_page_id :integer
#
# Indexes
#
#  index_pages_on_parent_page_id_and_position  (parent_page_id,position)
#  index_pages_on_position                     (position)
#  index_pages_on_slug                         (slug) UNIQUE
#

require 'spec_helper'

describe Page do
  before do
    @page = FactoryBot.create(:page)
  end

  it "is valid from FactoryBot" do
    expect(@page).to be_valid
  end

  it "requires a slug" do
    @page.slug = nil
    expect(@page).not_to be_valid
  end

  it "requires a body" do
    @page.body = nil
    expect(@page).not_to be_valid
  end

  it "requires a title" do
    @page.title = nil
    expect(@page).not_to be_valid
  end

  it "cannot have a space in the slug" do
    @page.slug = "A test"
    expect(@page).not_to be_valid
  end

  it "is a parent" do
    expect(described_class.parent_or_single).to eq([@page])
  end

  it "is an ordinary slug" do
    expect(described_class.ordinary).to eq([@page])
  end

  context "page with a child" do
    before do
      @child = FactoryBot.create(:page, parent_page: @page)
    end

    it "marks the page as a parent" do
      expect(@page).to be_parent
    end
  end
end
