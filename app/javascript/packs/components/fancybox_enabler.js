/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
$(document).ready(() =>
  $(".fancybox").fancybox({
    type: "iframe",
    maxWidth: 800,
    maxHeight: 600,
    width: "70%",
    height: "70%",
    autoSize: false,
    closeClick: false,
    openEffect: "none",
    closeEffect: "none"
  })
);


$(() =>
  $(document).on("click", ".js--dynamicFancybox", function() {
    const val = $(".js--fancyboxUrl").val();
    return $(this).attr("href", val);
  })
);
