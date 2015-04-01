module SortableObject
  # POST /<object>/:id/update_row_order (via AJAX)
  def update_row_order
    obj = sortable_object
    new_position = params[:row_order_position].to_i + 1
    obj.position = new_position
    obj.save
    render nothing: true
  end
end
