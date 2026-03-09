# frozen_string_literal: true

module CacheInstrumentation
  class Tracker
    attr_reader :operations

    def initialize
      @operations = { read: 0, write: 0, fetch_hit: 0, delete: 0 }
      @total_duration_ms = 0.0
    end

    def record(event_name, duration_ms, _payload)
      op_type = event_name.sub('.active_support', '').sub('cache_', '').to_sym
      @operations[op_type] = (@operations[op_type] || 0) + 1
      @total_duration_ms += duration_ms
    end

    def summary
      total_ops = @operations.values.sum
      {
        operations: @operations,
        total_ops: total_ops,
        total_duration_ms: @total_duration_ms.round(2),
        avg_duration_ms: (total_ops > 0 ? @total_duration_ms / total_ops : 0).round(3)
      }
    end
  end

  EVENTS = %w[cache_read cache_write cache_fetch_hit cache_delete].freeze

  def self.measure(label = "cache_measurement")
    tracker = Tracker.new
    subscribers = []

    EVENTS.each do |event|
      subscribers << ActiveSupport::Notifications.subscribe("#{event}.active_support") do |name, start, finish, _id, _payload|
        duration_ms = (finish - start) * 1000.0
        tracker.record(name, duration_ms, nil)
      end
    end

    result = yield

    summary = tracker.summary
    Rails.logger.info("[CacheInstrumentation] #{label}: #{summary.to_json}")

    [result, summary]
  ensure
    subscribers.each { |s| ActiveSupport::Notifications.unsubscribe(s) }
  end
end
