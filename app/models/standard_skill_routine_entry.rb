class StandardSkillRoutineEntry < ActiveRecord::Base
    belongs_to :standard_skill_entry
    belongs_to :standard_skill_routine
    acts_as_list :scope => :standard_skill_routine

    attr_accessible :standard_skill_routine_id, :standard_skill_entry_id, :position

    validates :standard_skill_entry_id, :standard_skill_routine_id, :presence => true
    validates :position, :presence => true, :numericality => {:only_integer => true}

    validate :no_more_than_18_skill_entries
    validate :no_more_than_12_non_riding_skills
    validate :each_skill_must_be_different_number

    def skill_number_and_letter
        standard_skill_entry.skill_number_and_letter
    end

    def description
        standard_skill_entry.description
    end

    def add_standard_skill_routine_entry(params)
      # keep the position values between 1 and 18
      if self.standard_skill_routine_entries.size > 1
        # if the user doesn't specify a position, default to 'end of list'
        if params[:position].nil? or params[:position].empty? or params[:position].to_i > self.standard_skill_routine_entries.last.position+1
          params[:position] = self.standard_skill_routine_entries.last.position+1
        elsif params[:position].to_i < 1
          params[:position] = 1
        end
      elsif params[:position].nil? or params[:position].empty?
          params[:position] = 1
      end
      self.standard_skill_routine_entries.build(params)
    end

    private

    def no_more_than_18_skill_entries
      # XXX should not traverse this 'standard_skill_routine' object?
      if standard_skill_routine.standard_skill_routine_entries.count >= 18
          if new_record?
              errors[:base] << "You cannot specify more than 18 entries in your skills routine"
          end
      end
    end

    def no_more_than_12_non_riding_skills
      count = 0
      standard_skill_routine.standard_skill_routine_entries.each do |skill|
        if skill.standard_skill_entry.non_riding_skill
            count += 1
        end
      end
      if count > 12
        if new_record?
          errors[:base] << "You cannot have more than 12 non-riding-skills (skills above 100)"
        end
      end
    end


    def each_skill_must_be_different_number
      if new_record?
        standard_skill_routine.standard_skill_routine_entries.each do |first_entry|
          if first_entry.standard_skill_entry.number == standard_skill_entry.number
              errors[:base] << "You cannot have 2 skills with the same number (#{first_entry.standard_skill_entry.number})"
          end
        end
      end
    end

end
