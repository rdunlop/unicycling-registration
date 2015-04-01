module SortableObject
  # POST /<object>/:id/update_row_order (via AJAX)
  def update_row_order
    new_position = params[:row_order_position].to_i + 1
    sortable_object.position = new_position
    sortable_object.save
    render nothing: true
  end
end
