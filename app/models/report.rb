# == Schema Information
#
# Table name: reports
#
#  id           :integer          not null, primary key
#  report_type  :string           not null
#  url          :string
#  completed_at :datetime
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class Report < ApplicationRecord
  mount_uploader :url, PdfUploader

  validates :report_type, inclusion: { in: ["registration_summary"] }
end
