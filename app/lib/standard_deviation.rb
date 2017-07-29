class StandardDeviation
  attr_reader :array

  def initialize(a)
    @array = a
  end

  def standard_deviation
    result = Math.sqrt(sample_variance)

    return 0.0 if result.nan?

    result
  end

  def num_standards_from_the_mean(value)
    return 0.0 if value.nil?
    return 0.0 if standard_deviation.zero?
    ((value - mean) / standard_deviation).abs
  end

  def sum
    array.inject(0){ |accum, i| accum + i }
  end

  def mean
    return 0.0 if array.length.zero?
    sum / array.length.to_f
  end

  def sample_variance
    m = mean
    calc_sum = array.inject(0){ |accum, i| accum + (i - m)**2 }
    calc_sum / (array.length - 1).to_f
  end
end
