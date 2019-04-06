module TracksEnteredBy
  extend ActiveSupport::Concern

  included do
    belongs_to :entered_by, class_name: 'User', foreign_key: :entered_by_id

    # this cannot be applied globally due to older data existing in the system?
    validates :entered_by, :entered_at, presence: true
  end
end
