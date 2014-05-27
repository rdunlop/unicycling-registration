$(document).on "click", ".js--toggle", ->
    to_toggle = $(this).data("toggle")
    $("." + to_toggle).toggle()
