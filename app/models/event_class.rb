class EventClass < ActiveRecord::Base
    attr_accessible :name

    validates :name, :presence => true, :uniqueness => true

    def to_s
        name
    end
end
