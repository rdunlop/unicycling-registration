class JudgeType < ActiveRecord::Base
    has_many :judges, :dependent => :destroy
    has_many :competitions, :through => :judges
    has_many :scores, :through => :judges

    validates :name, :presence => true, :uniqueness => true
    validates :event_class, :inclusion => { :in => Competition.scoring_classes }

    validates :val_1_description, :presence => true
    validates :val_2_description, :presence => true
    validates :val_3_description, :presence => true
    validates :val_4_description, :presence => true

    validates :val_1_max, :presence => true
    validates :val_2_max, :presence => true
    validates :val_3_max, :presence => true
    validates :val_4_max, :presence => true
    validates :boundary_calculation_enabled, :inclusion => { :in => [true, false] }

    after_initialize :init

    def init
        self.val_1_max ||= 10
        self.val_2_max ||= 10
        self.val_3_max ||= 10
        self.val_4_max ||= 10
        self.boundary_calculation_enabled = false if self.boundary_calculation_enabled.nil?
    end


    def to_s
        name
    end
end
