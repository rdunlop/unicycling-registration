# Describe the way in which to display a TimeResult for various consumers
#
# including:
# summary
# table-display
# form-entry
class ResultDisplayer::TimeResult
  attr_reader :competition

  def initialize(competition)
    @competition = competition
  end

  def summary_headings
    results = []
    if @competition.imports_times?
      results << "Time"
    else
      results << "Points"
    end
    if @competition.has_num_laps?
      results << "# Laps"
    end

    results
  end

  def summary_result_data(import_result)
    results = []
    if @competition.imports_times?
      results << import_result.full_time
    else
      results << import_result.points.to_s
    end
    if @competition.has_num_laps?
      results << import_result.number_of_laps
    end
    results
  end

  def headings
    result = []
    if @competition.data_entry_format.hours?
      result << TimeResult.human_attribute_name(:hours)
    end
    result << TimeResult.human_attribute_name(:minutes)
    result << TimeResult.human_attribute_name(:seconds)
    if @competition.data_entry_format.hundreds?
      result << TimeResult.human_attribute_name(:hundreds)
    end
    if @competition.data_entry_format.thousands?
      result << TimeResult.human_attribute_name(:thousands)
    end
    if @competition.has_penalty?
      result << "Penalties"
    end
    if @competition.has_num_laps?
      result << "# Laps"
    end
    result
  end

  def result_data(time_result)
    result = []

    if @competition.data_entry_format.hours?
      result << time_result.facade_hours
      result << time_result.facade_minutes
    else
      result << time_result.minutes
    end
    result << time_result.seconds
    if @competition.data_entry_format.hundreds?
      result << time_result.facade_hundreds
    end
    if @competition.data_entry_format.thousands?
      result << time_result.thousands
    end
    if @competition.has_penalty?
      result << time_result.number_of_penalties
    end
    if @competition.has_num_laps?
      result << time_result.number_of_laps
    end

    result
  end

  def form_label_symbols
    results = []
    if @competition.data_entry_format.hours?
      results << :facade_hours
      results << :facade_minutes
    else
      results << :minutes
    end
    results << :seconds
    if @competition.data_entry_format.hundreds?
      results << :facade_hundreds
    end
    if @competition.data_entry_format.thousands?
      results << :thousands
    end
    if @competition.has_penalty?
      results << :number_of_penalties
    end
    if @competition.has_num_laps?
      results << :number_of_laps
    end

    results
  end

  def form_inputs
    results = []
    if @competition.data_entry_format.hours?
      results << [:facade_hours, {min: 0}]
      results << [:facade_minutes, {min: 0}]
    else
      results << [:minutes, {min: 0}]
    end
    results << [:seconds, {min: 0}]
    if @competition.data_entry_format.hundreds?
      results << [:facade_hundreds, {min: 0}]
    end
    if @competition.data_entry_format.thousands?
      results << [:thousands, {min: 0}]
    end

    if @competition.has_penalty?
      results << [:number_of_penalties, {}]
    end
    if @competition.has_num_laps?
      results << [:number_of_laps, {min: 1}]
    end

    results
  end
end
