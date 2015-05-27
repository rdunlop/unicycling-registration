class CompetitionStateMachine
  attr_accessor :competition

  def initialize(competition)
    @competition = competition
  end

  def lock
    competition.touch(:locked_at)
  end

  def unlock
    competition.update_attribute(:locked_at, nil)
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
    Competition.transaction do
      pdf_creator.publish!
      competition.touch(:published_at) || raise("Unable to save attributes")
    end
    true
  rescue Exception => e
    false
  end

  def unpublish
    Competition.transaction do
      pdf_creator.unpublish!
      competition.update_attribute(:published_at, nil) || raise("Unable to save attributes")
    end
    true
  rescue Exception => e
    false
  end

  private

  def pdf_creator
    CreatesCompetitionResultsPdf.new(competition)
  end
end
