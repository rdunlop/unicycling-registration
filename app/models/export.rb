# == Schema Information
#
# Table name: exports
#
#  id             :bigint           not null, primary key
#  export_type    :string           not null
#  exported_by_id :integer          not null
#  file           :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_exports_on_exported_by_id  (exported_by_id)
#

class Export < ApplicationRecord
  belongs_to :exported_by, class_name: "User"

  validates :exported_by, presence: true
  validates :export_type, presence: true

  mount_uploader :file, FileUploader
end
