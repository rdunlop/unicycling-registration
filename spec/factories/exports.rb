FactoryBot.define do
  factory :export do
    association :exported_by, factory: :user
    export_type { "results" }
    file { Rack::Test::UploadedFile.new(file_fixture('invalid_sample_wave_assignments.xlsx'), 'text/plain') }
  end
end

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
