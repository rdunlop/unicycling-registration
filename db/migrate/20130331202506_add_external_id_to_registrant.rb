class AddExternalIdToRegistrant < ActiveRecord::Migration
  class Registrant < ActiveRecord::Base
  end

  def up
    add_column :registrants, :external_id, :integer
    Registrant.reset_column_information
    next_comp_id = 1
    next_noncomp_id = 2000
    Registrant.order("id ASC").each do |reg|
      if reg.competitor?
        reg.external_id = next_comp_id
        next_comp_id += 1
      else
        reg.external_id = next_noncomp_id
        next_noncomp_id += 1
      end
      reg.save(:validate => false)
    end
  end

  def down
    remove_column :regsitrants, :external_id
  end
end
