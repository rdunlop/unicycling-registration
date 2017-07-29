class StandardDeviationPresenter
  attr_accessor :standard_deviation
  MAX_FROM_MEAN = 3.0
  MAX_COLOR_VALUE = 180

  def initialize(standard_deviation)
    @standard_deviation = standard_deviation
  end

  def style_classes(value)
    return {} unless standard_deviation

    sftm = standard_deviation.num_standards_from_the_mean(value)
    from_mean = [sftm, MAX_FROM_MEAN.to_f].min

    scaled_value = (MAX_COLOR_VALUE / MAX_FROM_MEAN) * from_mean

    color_hex = (255 - scaled_value.to_i).to_s(16) # hex
    color = "##{color_hex}#{color_hex}#{color_hex}"
    deviation = sftm.round(1)
    mean = standard_deviation.mean.round(1)
    { style: "background-color: #{color}", title: "Mean: #{mean}. Deviation: #{deviation}" }
  end
end
