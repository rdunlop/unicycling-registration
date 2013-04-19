class JudgeType < ActiveRecord::Base
    belongs_to :event_class

    #has_many :judges, :dependent => :destroy
    #has_many :event_categories, :through => :judges
    #has_many :scores, :through => :judges

    attr_accessible :name, :event_class_id
    attr_accessible :val_1_description, :val_2_description, :val_3_description, :val_4_description
    attr_accessible :val_1_max, :val_2_max, :val_3_max, :val_4_max
    #attr_accessible :boundary_calculation_enabled

    validates :name, :presence => true, :uniqueness => true
    validates :event_class_id, :presence => true

    validates :val_1_description, :presence => true
    validates :val_2_description, :presence => true
    validates :val_3_description, :presence => true
    validates :val_4_description, :presence => true

    validates :val_1_max, :presence => true
    validates :val_2_max, :presence => true
    validates :val_3_max, :presence => true
    validates :val_4_max, :presence => true
    #validates :boundary_calculation_enabled, :inclusion => { :in => [true, false] }

    after_initialize :init

    def init
        self.val_1_max ||= 10
        self.val_2_max ||= 10
        self.val_3_max ||= 10
        self.val_4_max ||= 10
    end


    def to_s
        name
    end
end
