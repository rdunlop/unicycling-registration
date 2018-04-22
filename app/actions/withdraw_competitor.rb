class WithdrawCompetitor
  def self.perform(competitor)
    competitor.update(status: "withdrawn", withdrawn_at: Time.current)
  end
end
