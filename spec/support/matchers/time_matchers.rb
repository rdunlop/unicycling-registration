# Mac only offers microsecond precision, so Time.current, Time.new, etc, as does
# Postgres. Linux provides nanosecond precision, so sometimes #eq will work locally,
# but fail on CI. Use this instead.
RSpec::Matchers.define :match_microseconds do |_expected|
  include TimeMatcherHelpers

  def round_to(time)
    time.change(usec: time.nsec / 1000)
  end

  def precision
    "microsecond precision"
  end
end

RSpec::Matchers.define :match_seconds do |_expected|
  include TimeMatcherHelpers

  def round_to(time)
    Time.at(time.to_i)
  end

  def precision
    "second precision"
  end
end

module TimeMatcherHelpers
  def self.included(base)
    def format_time(time) # rubocop:disable Lint/NestedMethodDefinition
      time.strftime("%Y-%m-%d %H:%M:%S.#{'%09d' % round_to(time).nsec} %z") # rubocop:disable Style/FormatString
    end

    base.match do |actual|
      round_to(expected) == round_to(actual)
    end

    base.failure_message do |actual|
      "\nexpected: #{format_time(expected)}\n     got: #{format_time(actual)}\n\n(truncated to #{precision})\n"
    end

    base.failure_message_when_negated do |actual|
      "\nexpected: value != #{format_time(expected)}\n     got: #{format_time(actual)}\n\n(truncated to #{precision})\n"
    end
  end
end
