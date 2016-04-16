module FeedbacksHelper
  def message_summary(feedback)
    truncate(feedback.message, separator: ' ', length: 50)
  end
end
