$ ->
  if $(".js--blockVisibleSource").length > 0
    new BlockVisibleBasedOnSelect($(".js--blockVisibleSource"), $(".js--blockVisibleTarget"), "is--hidden")
