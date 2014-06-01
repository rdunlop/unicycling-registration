class TimeResultPresenter
  include TimePrintable
  attr_accessor :minutes, :seconds, :thousands

  def initialize(time_in_thousands)
    @thousands = time_in_thousands % 1000
    seconds_remaining = (time_in_thousands - @thousands) / 1000
    @seconds = seconds_remaining % 60
    @minutes = (seconds_remaining - @seconds) / 60
  end
end
