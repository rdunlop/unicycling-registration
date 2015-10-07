# == Schema Information
#
# Table name: pages
#
#  id         :integer          not null, primary key
#  slug       :string           not null
#  created_at :datetime
#  updated_at :datetime
#
# Indexes
#
#  index_pages_on_slug  (slug) UNIQUE
#

require 'spec_helper'

describe Page do
  before(:each) do
    @page = FactoryGirl.create(:page)
  end

  it "is valid from FactoryGirl" do
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

end
