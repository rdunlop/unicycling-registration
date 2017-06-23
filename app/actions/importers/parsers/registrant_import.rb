# CsvExtractor converts from file into array-of-arrays
# Processor converts from array-of-arrays into array of hashes
# {
#   id: "1",
#   first_name: "Bob",
#   last_name: "Smith",
#   birthday: "10/4/76",
#   gender: "m",
#   events: [
#      {
#        name: "100m",
#        signed_up: true,
#        best_time: "20.03",
#        choices: [
#          { "Team Name" => 100m" }
#        ],
#      }
#   ]
# }
class Importers::Parsers::RegistrantImport
  def extract_file(file)
    arrays = Importers::CsvExtractor.new(file).extract_csv
    [
      {
        id: "1",
        first_name: "Bob",
        last_name: "Smith",
        birthday: "10/4/76",
        gender: "m",
        events: [
          {
            name: "100m",
            signed_up: true,
            best_time: "20.03",
            choices: [
              { "Team Name" => "100m" }
            ]
          }
        ]
      }
    ]
  end
end
