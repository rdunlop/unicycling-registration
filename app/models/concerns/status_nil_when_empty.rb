module StatusNilWhenEmpty
  extend ActiveSupport::Concern

  included do
    nilify_blanks only: %i[status], before: :validation
  end
end
