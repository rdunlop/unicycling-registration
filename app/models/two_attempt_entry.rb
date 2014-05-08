class TwoAttemptEntry
  include ActiveModel::Validations
  include ActiveModel::Conversion

  attr_accessor :user, :competition
  attr_accessor :bib_number, :is_start_time
  attr_accessor :raw_data_1, :raw_data_2
  attr_accessor :minutes_1, :minutes_2, :seconds_1, :seconds_2, :thousands_1, :thousands_2
  attr_accessor :dq_1, :dq_2

  validates :bib_number, :raw_data_1, presence: true

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

  def save
    ImportResult.transaction do
      i1 = ImportResult.new(
        user_id: user.id,
        raw_data: raw_data_1,
        bib_number: bib_number,
        minutes: minutes_1,
        seconds: seconds_1,
        thousands: thousands_1,
        disqualified: dq_1,
        competition_id: competition.id
        )
      i1.save!

      if raw_data_2.present?
        i2 = ImportResult.new(
          user_id: user.id,
          raw_data: raw_data_2,
          bib_number: bib_number,
          minutes: minutes_2,
          seconds: seconds_2,
          thousands: thousands_2,
          disqualified: dq_2,
          competition_id: competition.id
          )
        i2.save!
      end
    end
  end

  def new_record?
    true
  end

  def to_param
    nil
  end

  def persisted?
    false
  end
end
