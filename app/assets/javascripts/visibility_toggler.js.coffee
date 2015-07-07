# Public: if you set a "js--toggle" class on an object, it will
# hide the "toggle-target" elements initially,
# and show them on click.
$ ->
  $(".js--toggle").each ->
    target = $(this).data("toggle-target")
    $(target).hide()

    $(this).on "click", ->
      $(target).show()

