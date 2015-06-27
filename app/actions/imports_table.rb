class ImportsTable
  attr_accessor :target_class
  def initialize(target_class)
    @target_class = target_class
  end

  def import(hash)
    new_hash = convert_hash(hash)
    obj = @target_class.new(new_hash)
    if obj.save
      true
    else
      Rails.logger.debug "Error doing import of #{new_hash}"
      obj.errors.each do |error|
        Rails.logger.debug error
      end
      false
    end
  end

  private

  def convert_hash(hash)
    new_hash = {}
    hash.keys.each do |key|
      case key.to_sym
      when :lookup_user_id_by_email
        user = User.find_by!(email: hash[key].downcase)
        new_hash["user_id"] = user.id
      when :expense_item_lookup_by_name
        ei = ExpenseItem.find_by!(name: hash[key])
        new_hash["expense_item_id"] = ei.id
      when :event_id_lookup_by_name
        event = Event.find_by!(name: hash[key])
        new_hash["event_id"] = event.id
      when :event_category_lookup_by_name_filter_by_event_id
        event = Event.find(new_hash["event_id"])
        if event.event_categories.count == 1
          event_category = event.event_categories.first
        else
          event_category = event.event_categories.find_by!(name: hash[key])
        end

        new_hash["event_category_id"] = event_category.id
      else
        new_hash[key] = hash[key]
      end
    end
    new_hash
  end
end
