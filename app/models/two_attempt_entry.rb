class TwoAttemptEntry
  include ActiveModel::Validations
  include ActiveModel::Conversion

  attr_accessor :user, :competition
  attr_accessor :bib_number, :is_start_time
  attr_accessor :minutes_1, :minutes_2, :seconds_1, :seconds_2, :thousands_1, :thousands_2
  attr_accessor :dq_1, :dq_2

  validates :bib_number, presence: true

  delegate :find_competitor_with_bib_number, to: :competition

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

  def registrant_name
    Registrant.find_by_bib_number(bib_number)
  end

  def has_matching_competitor?
    competition.find_competitor_with_bib_number(bib_number)
  end

  def self.entries_for(user, competition, is_start_time)
    results = []
    user.import_results.where(is_start_time: is_start_time, competition: competition).order(:attempt_number, :created_at, :id).each do |ir|
      found = false
      results.each do |res|
        if res.bib_number == ir.bib_number
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
          is_start_time: is_start_time,
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
        if minutes_2.present?
          i2.save!
        end
        true
      end
    rescue ActiveRecord::RecordInvalid => invalid
      false
    end
  end

  def full_time_1
    i1.full_time
  end

  def full_time_2
    i2.full_time
  end

  delegate :errors, to: :i1

  def i1
     @i1 ||= ImportResult.new(
        attempt_number: 1,
        user_id: user.try(:id),
        competition_id: competition.try(:id),
        bib_number: bib_number,
        is_start_time: is_start_time,

        minutes: minutes_1,
        seconds: seconds_1,
        thousands: thousands_1,
        status: dq_1 ? "DQ" : nil
        )
  end

  def i2
     @i2 ||= ImportResult.new(
        attempt_number: 2,
        user_id: user.id,
        competition_id: competition.id,
        bib_number: bib_number,
        is_start_time: is_start_time,

        minutes: minutes_2,
        seconds: seconds_2,
        thousands: thousands_2,
        status: dq_2 ? "DQ" : nil
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
