FactoryGirl.define do
  factory :report do
    report_type "registration_summary"
    url "some url"
  end
end

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
