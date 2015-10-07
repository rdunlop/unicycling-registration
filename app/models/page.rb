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

class Page < ActiveRecord::Base

  validates :slug, presence: true, uniqueness: true
  validates :title, :body, presence: true
  validate :slug_cannot_have_special_characters

  translates :title, :body, fallbacks_for_empty_translations: true
  accepts_nested_attributes_for :translations

  # SHOULD slugify the slug

  def to_s
    title
  end

  private

  def slug_cannot_have_special_characters
    if slug.present? && slug.include?(" ")
      errors[:base] << "Slug cannot have spaces"
    end
  end

end
