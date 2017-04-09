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
      results << "Points" # TODO: Extract this into a separate Point-type object?
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
    form_inputs.map{|field_name, _| TimeResult.human_attribute_name(field_name) }
  end

  # get the value of each field from the passed time_result/import_result object
  def result_data(time_result)
    form_inputs.map do |field_name, _|
      time_result.public_send(field_name)
    end
  end

  def form_label_symbols
    form_inputs.map{|field_name, _| field_name }
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
