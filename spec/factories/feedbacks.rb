FactoryGirl.define do
  factory :feedback do
    message "Please help me with registration"
    user
    status "new"
    entered_email nil
  end
end
