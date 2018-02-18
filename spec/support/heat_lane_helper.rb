def create_competitor(competition, bib_number, heat, lane)
  competitor = FactoryBot.create(:event_competitor, competition: competition)
  reg = competitor.members.first.registrant
  reg.update_attribute(:bib_number, bib_number)
  if heat && lane
    FactoryBot.create(:lane_assignment, competition: competition, competitor: competitor, heat: heat, lane: lane)
  end
end
