exports = exports ? @

class BlockVisibleBasedOnSelect
  constructor: (@$select_element, @$target_elements, @hiddenClass = "is--hidden") ->
    @$select_element.on "change", @_toggleVisibility
    @_toggleVisibility()

  _toggleVisibility: =>
    $.each @$target_elements, (_index, element) =>
      $el = $(element)
      if @_currentValue() == null
        $el.removeClass(@hiddenClass)
        return

      if $el.data("show")
        # show this element only if it should be shown
        # the data element may be an array, which would be comma-delimited
        if $el.data("show").indexOf(@_currentValue()) >= 0
          $el.removeClass(@hiddenClass)
        else
          $el.addClass(@hiddenClass)

  _currentValue: =>
    if @$select_element.val() == ""
      null
    else
      @$select_element.val()


exports.BlockVisibleBasedOnSelect = BlockVisibleBasedOnSelect
