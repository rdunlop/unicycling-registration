module CompetitorsHelper
  def conditional_form_for(models, condition, &block)
    if condition
        form_for(models, &block)
    else
        block.call(nil)
        return nil
    end
  end
end
