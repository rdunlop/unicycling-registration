/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
// hide the refresh button once clicked
$(() =>
  $(".js--usa_member_status_refresh").click(function(el) {
    $(el.target).addClass("is--hidden");
    $(".js--usa_member_status").addClass("is--hidden");
    return $(".js--usa_member_refresh_notice").removeClass("is--hidden");
  })
);
