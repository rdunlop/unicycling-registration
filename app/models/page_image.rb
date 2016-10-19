# == Schema Information
#
# Table name: page_images
#
#  id         :integer          not null, primary key
#  page_id    :integer          not null
#  name       :string           not null
#  image      :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class PageImage < ApplicationRecord
  mount_uploader :image, ImageUploader

  belongs_to :page

  validates :page, :name, :image, presence: true
end
