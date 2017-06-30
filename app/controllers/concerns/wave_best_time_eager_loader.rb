module WaveBestTimeEagerLoader
  # Eager load the relationships necessary
  # to display the age group, gender, etc
  # for Wave displays/exports
  def eager_load_competitors_relations(competitors)
    competitors.includes(
      :age_group_entry,
      members: :registrant,
      competition: [age_group_type: :age_group_entries]
    )
  end
end
