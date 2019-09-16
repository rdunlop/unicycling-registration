# hide the refresh button once clicked
$ ->
  $(".js--organization_member_status_refresh").click (el) ->
    $(el.target).addClass("is--hidden")
    $(".js--organization_member_status").addClass("is--hidden")
    $(".js--organization_member_refresh_notice").removeClass("is--hidden")
    setTimeout ->
      window.location = window.location;
    , 5000;
