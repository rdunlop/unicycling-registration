$(document).ready ->
  $(".fancybox").fancybox
    type: "iframe"
    maxWidth: 800
    maxHeight: 600
    width: "70%"
    height: "70%"
    autoSize: false
    closeClick: false
    openEffect: "none"
    closeEffect: "none"


$ ->
  $(document).on "click", ".js--dynamicFancybox", ->
    val = $(".js--fancyboxUrl").val()
    $(this).attr("href", val)
