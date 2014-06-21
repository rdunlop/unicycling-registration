class CompetitionStateMachine
  attr_accessor :competition

  def initialize(competition)
    @competition = competition
  end

  def lock
    competition.update_attribute(:locked, true)
  end

  def unlock
    competition.update_attribute(:locked, false)
  end

  def publish
    begin
      Competition.transaction do
        pdf_creator.publish!
        competition.update_attributes({published: true, published_date: DateTime.now})
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
        competition.update_attributes({published: false, published_date: nil})
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
