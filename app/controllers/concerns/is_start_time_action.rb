module IsStartTimeAction
  def set_is_start_time
    @is_start_time = params[:is_start_times] && params[:is_start_times] == "true"
  end
end
