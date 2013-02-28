$ ->
  $(document).on "click", ".delete_expenses_button", ->
    button = $(this)
    check = $("#" + button.data("checkbox-id"))
    check.prop('checked', true)
    row = $("#" + button.data("row-id"))
    row.fadeOut(500)
    return false
