# To use this concern:
# Define a `sortable_object` method which returns the object being sorted.
# also be sure to use a `before_action` to call `authorize` before this method is called.
module SortableObject
  # POST /<object>/:id/update_row_order (via AJAX)
  def update_row_order
    obj = sortable_object
    new_position = params[:row_order_position].to_i + 1
    obj.position = new_position
    obj.save
    head :ok
  end
end
