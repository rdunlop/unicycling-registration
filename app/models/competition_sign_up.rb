# a presenter pattern for Competition
class CompetitionSignUp
  attr_accessor :competition

  def initialize(competition)
    @competition = competition

    @agt = competition.age_group_type

    all_registrants = Registrant.active.where(:competitor => true).order(:bib_number)
    signed_up_registrants = competition.signed_up_registrants
    @signed_up_list = {}
    @not_signed_up_list = {}
    age_group_entries.each do |description, gender|
      @signed_up_list[description] = []
      @not_signed_up_list[description] = []
    end

    all_registrants.each do |reg|
      calculated_ag = @agt.age_group_entry_for(reg.age, reg.gender, reg.wheel_size_for_event(competition.event).id).to_s unless @agt.nil?
      calculated_ag = reg.gender if @agt.nil?
      next if calculated_ag.empty?

      if signed_up_registrants.include?(reg)
        @signed_up_list[calculated_ag] << reg
      else
        @not_signed_up_list[calculated_ag] << reg
      end
    end
  end

  def competition
    @competition
  end

  def age_group_entries
    return @agt.age_group_entries.map {|age| [age.to_s, age.gender] } unless @agt.nil?
    return [["Male", "Male"], ["Female", "Female"]]
  end

  def signed_up_list(description)
    @signed_up_list[description]
  end

  def not_signed_up_list(description)
    if EventConfiguration.singleton.usa?
      @not_signed_up_list[description]
    else
      []
    end
  end


end
