class Importers::Parsers::TwoAttemptSlalom < Importers::Parsers::Base
  def extract_file
    # need a spec
    Importers::CsvExtractor.new(file, separator: ';').extract_csv
  end

  # Example data
  # 30;Smith;Ramona;19,64;19,40;Switzerland;23;w;IUF-Slalom
  # 65;Rondeau;Antoine;24,66;disq;France;22;m;IUF-Slalom
  # 268;Jorgensen;Jonas ;abgem;abgem;Denmark;20;m;IUF-Slalom
  def process_row(raw)
    time_one = raw[3]
    time_two = raw[4]
    status_1 = translate_status_column(time_one)
    status_2 = translate_status_column(time_two)

    return nil if status_1.nil? && status_2.nil?
    minutes_1, seconds_1, thousands_1 = nil
    minutes_2, seconds_2, thousands_2 = nil

    if status_1 == "active"
      broken_apart = time_one.split(",")
      minutes_1 = 0
      seconds_1 = broken_apart[0]
      thousands_1 = broken_apart[1].to_i * 10
    end

    if status_2 == "active"
      broken_apart = time_two.split(",")
      minutes_2 = 0
      seconds_2 = broken_apart[0]
      thousands_2 = broken_apart[1].to_i * 10
    end

    {
      bib_number: raw[0],
      minutes_1: minutes_1,
      seconds_1: seconds_1,
      thousands_1: thousands_1,
      status_1: status_1,

      minutes_2: minutes_2,
      seconds_2: seconds_2,
      thousands_2: thousands_2,
      status_2: status_2
    }
  end

  def translate_status_column(data)
    Importers::StatusTranslation::German.translate(data)
  end
end
