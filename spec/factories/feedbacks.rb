FactoryGirl.define do
  factory :feedback do
    message "Please help me with registration"
    user
    status "new"
    entered_email nil

    trait :resolved do
      status "resolved"
      association :resolved_by, factory: :user
      resolved_at { DateTime.current }
      resolution "Sent him an e-mail"
    end
  end
end

# == Schema Information
#
# Table name: feedbacks
#
#  id             :integer          not null, primary key
#  user_id        :integer
#  entered_email  :string
#  message        :text
#  status         :string           default("new"), not null
#  resolved_at    :datetime
#  resolved_by_id :integer
#  resolution     :text
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
