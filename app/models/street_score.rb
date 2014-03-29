class StreetScore < ActiveRecord::Base
  include Judgeable

    validates :val_1, :presence => true, :numericality => {:greater_than_or_equal_to => 0}
    validate :values_within_judge_type_bounds

    def values_within_judge_type_bounds
        if judge and judge.judge_type and self.val_1
            jt = judge.judge_type
            if self.val_1 > jt.val_1_max
                errors[:val_1] << "val_1 must be <= #{jt.val_1_max}"
            end
        end
    end

    def Total
      if self.invalid?
        0
      else
        (self.val_1)
      end
    end
end
