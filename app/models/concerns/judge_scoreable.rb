module JudgeScoreable
  extend ActiveSupport::Concern

  included do
    validates *self.score_fields, :presence => true, :numericality => {:greater_than_or_equal_to => 0}
    validate :values_within_judge_type_bounds
  end

  module ClassMethods
    def self.score_fields
      []
  end
  end



  def validate_judge_score(value_sym, max_score)
    if self.send(value_sym) > max_score
      errors[value_sym] << "#{value_sym.to_s} must be <= #{max_score}"
    end
  end

  def all_values_present
    self.class.score_fields.all? { |sym| self.send(sym) }
  end

  def values_within_judge_type_bounds
    if judge && judge.judge_type && all_values_present
      jt = judge.judge_type
      self.class.score_fields.each do |sym|
        validate_judge_score(sym, jt.send("#{sym}_max"))
      end
    end
  end

  def Total
    if self.invalid?
      0
    else
      self.class.score_fields.inject(0){ |sum, sym| sum + self.send(sym) }
    end
  end
end
