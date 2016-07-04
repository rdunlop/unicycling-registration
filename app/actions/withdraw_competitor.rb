class WithdrawCompetitor
  def self.perform(competitor)
    competitor.update_attributes(status: "withdrawn", withdrawn_at: DateTime.current)
  end
end
