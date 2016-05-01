# == Schema Information
#
# Table name: events
#
#  id                          :integer          not null, primary key
#  category_id                 :integer
#  position                    :integer
#  created_at                  :datetime
#  updated_at                  :datetime
#  name                        :string(255)
#  visible                     :boolean          default(TRUE), not null
#  accepts_music_uploads       :boolean          default(FALSE), not null
#  artistic                    :boolean          default(FALSE), not null
#  accepts_wheel_size_override :boolean          default(FALSE), not null
#  event_categories_count      :integer          default(0), not null
#  event_choices_count         :integer          default(0), not null
#  best_time_format            :string           default("none"), not null
#  standard_skill              :boolean          default(FALSE), not null
#
# Indexes
#
#  index_events_category_id                     (category_id)
#  index_events_on_accepts_wheel_size_override  (accepts_wheel_size_override)
#

module EventsHelper
  def scoring_link(judge, options = {})
    class_name = judge.competition.event_class

    judge_name = "#{judge.competition} - #{judge.judge_type.name}"
    case class_name
    when 'High/Long', 'High/Long Preliminary IUF 2015', 'High/Long Final IUF 2015'
      link_to judge_name, judge_distance_attempts_path(judge), options
    when 'Freestyle', "Artistic Freestyle IUF 2015"
      link_to judge_name, judge_scores_path(judge), options
    when 'Flatland'
      link_to judge_name, judge_scores_path(judge), options
    when 'Street', 'Street Final'
      link_to judge_name, judge_street_scores_path(judge), options
    when 'Standard Skill'
      link_to judge_name, judge_standard_skill_scores_path(judge), options
    else
      "please update the scoring_link function (#{judge.competition.event_class})"
    end
  end

  def start_finish_description(is_start_time)
    is_start_time = false if is_start_time == "false"
    is_start_time ? "Start Line Data" : "Finish Line Data"
  end
end
