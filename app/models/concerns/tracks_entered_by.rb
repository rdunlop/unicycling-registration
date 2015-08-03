module TracksEnteredBy
  extend ActiveSupport::Concern

  included do
    # this cannot be applied globally due to older data existing in the system?
    validates :entered_by_id, :entered_at, presence: true

    belongs_to :entered_by, class_name: 'User', foreign_key: :entered_by_id
  end
end
