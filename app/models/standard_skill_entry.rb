class StandardSkillEntry < ActiveRecord::Base

  has_many :standard_skill_routine_entries, :dependent => :destroy

  validates :number, :points, :description, :presence => true
  validates :letter, :presence => true, :uniqueness => {:scope => :number } # not allowed to have the same number/letter pair twice

  attr_accessible :number, :letter, :points, :description

  default_scope order('number, letter')

  def initialize_from_array(arr)
    self.number      = arr[0].to_i
    self.letter      = arr[1]
    self.points      = arr[2]
    self.description = arr[3]
  end

  def fullDescription
    self.skill_number_and_letter + " - " + self.description
  end

  def skill_number_and_letter
    self.number.to_s + "" + self.letter
  end

  def non_riding_skill
    number >= 100
  end

  def self.non_riding_skills
    where("standard_skill_entries.number >= 100")
  end

  def to_s
      fullDescription
  end
end
