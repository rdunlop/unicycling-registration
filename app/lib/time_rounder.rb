# Rounds thousands-based times to the
# correct nearest amount, based on the
# configuration of the competition

class TimeRounder
  attr_accessor :thousands, :data_entry_format

  def initialize(thousands, data_entry_format:)
    @thousands = thousands
    @data_entry_format = data_entry_format
  end

  def rounded_thousands
    rounding_function = if data_entry_format.lower_is_better?
                          :ceil
                        else
                          :floor
                        end

    rounding_columns = if data_entry_format.hundreds?
                         # INPUT from 0 to 999
                         #
                         # In case of 001 we want 010
                         # in case of 010 we want 010
                         # in case of 011 we want 020
                         -1
                       elsif data_entry_format.tens?
                         # INPUT from 0 to 999
                         #
                         # In case of 001 we want 100
                         # in case of 110 we want 200
                         -2
                       else
                         0
                       end

    thousands.send(rounding_function, rounding_columns)
  end
end
