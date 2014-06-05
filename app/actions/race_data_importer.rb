require 'upload'

class RaceDataImporter
  attr_accessor :competition, :user, :num_rows_processed, :errors

  def initialize(competition, user)
    @competition = competition
    @user = user
  end

  def process_lif(file, heat)
    upload = Upload.new
    raw_data = upload.extract_csv(file)
    raise StandardError.new("Competition not set for lane assignments") unless @competition.uses_lane_assignments
    self.num_rows_processed = 0
    self.errors = nil
    raw_data.shift #drop header row
    begin
      ImportResult.transaction do
        raw_data.each do |raw|
          lif_hash = upload.convert_lif_to_hash(raw)
          lane = lif_hash[:lane]
          id = get_id_from_lane_assignment(@competition, heat, lane)

          if id.nil?
            add_error "Unable to find Lane Assignment for heat #{heat} lane #{lane}"
            id = 0
          end

          result = @user.import_results.build
          result.raw_data = upload.convert_array_to_string(raw)
          result.competition = @competition
          result.bib_number = id
          result.minutes = lif_hash[:minutes]
          result.seconds = lif_hash[:seconds]
          result.thousands = lif_hash[:thousands]
          result.status = "DQ" if  (lif_hash[:disqualified] == "DQ")
          if result.save!
            self.num_rows_processed += 1
          end
        end
      end
    rescue ActiveRecord::RecordInvalid => invalid
      @errors = invalid
      return false
    end
    true
  end

  def process_csv(file, start_times)
    upload = Upload.new
    is_start_time = start_times || false
    # FOR EXCEL DATA:
    raw_data = upload.extract_csv(file)
    self.num_rows_processed = 0
    self.errors = nil
    begin
      ImportResult.transaction do
        raw_data.each do |raw|
          raw_data = upload.convert_array_to_string(raw)
          result = @competition.build_import_result_from_raw(raw)
          result.raw_data = raw_data
          result.user = @user
          result.competition = @competition
          result.is_start_time = is_start_time
          if result.save!
            self.num_rows_processed += 1
          end
        end
      end
    rescue ActiveRecord::RecordInvalid => invalid
      @errors = invalid
      return false
    end
  end

  def add_error(lane)
    error_message = "Missing Lane Assignment for Lane #{lane}"
    if self.errors.nil?
      self.errors = error_message
    else
      self.errors += error_message
    end
  end

  def get_id_from_lane_assignment(comp, heat, lane)
    la = LaneAssignment.find_by(competition: comp, heat: heat, lane: lane)
    if la.nil?
      id = nil
    else
      id = la.competitor.first_bib_number
    end
    id
  end
end
