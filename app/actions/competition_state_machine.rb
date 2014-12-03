class CompetitionStateMachine
  attr_accessor :competition

  def initialize(competition)
    @competition = competition
  end

  def lock
    competition.update_attributes(locked: true)
  end

  def unlock
    competition.update_attributes(locked: false)
  end

  def publish_age_group_entry(entry_id)
    existing = competition.published_age_group_entries.where(age_group_entry_id: entry_id).first
    if existing
      existing.destroy
    else
      entry = competition.published_age_group_entries.build(age_group_entry_id: entry_id)
      entry.save
    end
  end

  def publish
    begin
      Competition.transaction do
        pdf_creator.publish!
        competition.update_attributes({published: true}) || raise("Unable to save attributes")
      end
      true
    rescue Exception => e
      false
    end
  end

  def unpublish
    begin
      Competition.transaction do
        pdf_creator.unpublish!
        competition.update_attributes({published: false}) || raise("Unable to save attributes")
      end
      true
    rescue Exception => e
      false
    end
  end

  private

  def pdf_creator
    CreatesCompetitionResultsPdf.new(competition)
  end
end
