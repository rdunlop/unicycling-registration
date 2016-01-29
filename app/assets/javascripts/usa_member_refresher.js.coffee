# hide the refresh button once clicked
$ ->
  $(".js--usa_member_status_refresh").click (el) ->
    $(el.target).addClass("is--hidden")
    $(".js--usa_member_status").addClass("is--hidden")
    $(".js--usa_member_refresh_notice").removeClass("is--hidden")
