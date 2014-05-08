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

  def self.entries_for(user, competition, is_start_time)
    results = []
    user.import_results.where(is_start_time: is_start_time, competition: competition).order(:created_at).each do |ir|
      found = false
      results.each do |res|
        if res.bib_number == ir.bib_number
          res.raw_data_2 = ir.raw_data
          res.minutes_2 = ir.minutes
          res.seconds_2 = ir.seconds
          res.thousands_2 = ir.thousands
          res.dq_2 = ir.disqualified
          found = true
          break
        end
      end
      if not found
        results << TwoAttemptEntry.new(
          raw_data_1: ir.raw_data,
          bib_number: ir.bib_number,
          minutes_1: ir.minutes,
          seconds_1: ir.seconds,
          thousands_1: ir.thousands,
          dq_1: ir.disqualified,
          competition: competition,
          user: user
        )
      end
    end
    results
  end

  def save
    begin
      ImportResult.transaction do
        i1.save!
        if raw_data_2.present?
          i2.save!
        end
        true
      end
    rescue ActiveRecord::RecordInvalid => invalid
      false
    end
  end

  delegate :errors, to: :i1

  def i1
     @i1 ||= ImportResult.new(
        user_id: user.try(:id),
        competition_id: competition.try(:id),
        bib_number: bib_number,
        is_start_time: is_start_time,

        raw_data: raw_data_1,
        minutes: minutes_1,
        seconds: seconds_1,
        thousands: thousands_1,
        disqualified: dq_1
        )
  end

  def i2
     @i2 ||= ImportResult.new(
        user_id: user.id,
        competition_id: competition.id,
        bib_number: bib_number,
        is_start_time: is_start_time,

        raw_data: raw_data_2,
        minutes: minutes_2,
        seconds: seconds_2,
        thousands: thousands_2,
        disqualified: dq_2
        )
   end

  def new_record?
    true
  end

  def to_param
    nil
  end

  def id
    nil
  end

  def persisted?
    false
  end
end
