class Score < ActiveRecord::Base
    belongs_to :competitor
    belongs_to :judge

    attr_accessible :val_1, :val_2, :val_3, :val_4, :notes

    validates :judge_id, :presence => true, :uniqueness => {:scope => [:competitor_id]}
    validates :competitor_id, :presence => true

    validates :val_1, :presence => true, :numericality => {:greater_than_or_equal_to => 0} 
    validates :val_2, :presence => true, :numericality => {:greater_than_or_equal_to => 0} 
    validates :val_3, :presence => true, :numericality => {:greater_than_or_equal_to => 0} 
    validates :val_4, :presence => true, :numericality => {:greater_than_or_equal_to => 0} 
    validate :values_within_judge_type_bounds

    def user
        judge.user
    end

    def values_within_judge_type_bounds
        if judge and judge.judge_type and self.val_1 and self.val_2 and self.val_3 and self.val_4
            jt = judge.judge_type
            if self.val_1 > jt.val_1_max
                errors[:val_1] << "val_1 must be <= #{jt.val_1_max}"
            end
            if self.val_2 > jt.val_2_max
                errors[:val_2] << "val_2 must be <= #{jt.val_2_max}"
            end
            if self.val_3 > jt.val_3_max
                errors[:val_3] << "val_3 must be <= #{jt.val_3_max}"
            end
            if self.val_4 > jt.val_4_max
                errors[:val_4] << "val_4 must be <= #{jt.val_4_max}"
            end
        end
    end

    def Total
      if self.invalid?
        0
      else
        (self.val_1 + self.val_2 + self.val_3 + self.val_4 )
      end
    end

    # determining the place points for this score (by-judge)
    def tied
        if judge.event_category.score_calculator.ties(self) > 1
            true
        else
            false
        end
    end
end
