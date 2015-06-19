module StatusNilWhenEmpty
  extend ActiveSupport::Concern

  included do
    before_validation :clear_status_of_string
  end

  def clear_status_of_string
    self.status = nil if status == ""
  end
end
