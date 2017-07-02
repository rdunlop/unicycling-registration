module CompetitorHelper
  # display the competitor, with the team name as a bold first line,
  # if specified
  def name_with_team(competitor)
    ret = ''.html_safe # rubocop:disable Rails/OutputSafety
    if competitor.team_name.present?
      ret << content_tag(:b, competitor.team_name)
      ret << tag(:br)
    end
    competitor.active_members.each do |member|
      ret << member.to_s
      ret << tag(:br)
    end

    ret
  end
end
