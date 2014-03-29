class BoundaryScore < ActiveRecord::Base
  include Judgeable

    validates :number_of_people, :presence => true, :numericality => {:greater_than => 0}

    validates :major_dismount, :presence => true, :numericality => {:greater_than_or_equal_to => 0}
    validates :minor_dismount, :presence => true, :numericality => {:greater_than_or_equal_to => 0}
    validates :major_boundary, :presence => true, :numericality => {:greater_than_or_equal_to => 0}
    validates :minor_boundary, :presence => true, :numericality => {:greater_than_or_equal_to => 0}


    def Total
            major_dismount_devalue = 1
            minor_dismount_devalue = 0.5

            major_boundary_devalue = 0.5
            minor_boundary_devalue = 0.25

            if number_of_people <= 2
                people_scale = 1
            else
                # every time the team doubles in size, the scaling factor halves
                people_scale = number_of_people / 2.0
            end

        result = 10 - (((self.major_dismount * major_dismount_devalue) +
             (self.major_boundary * major_boundary_devalue) +
             (self.minor_dismount * minor_dismount_devalue) +
             (self.minor_boundary * minor_boundary_devalue)) / people_scale)

        if result < 0
            0
        else
            result
        end
    end
end
