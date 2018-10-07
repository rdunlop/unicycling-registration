/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
// Public: if you set a "js--toggle" class on an object, it will
// hide the "toggle-target" elements initially,
// and show them on click.
$(() =>
  $(".js--toggle").each(function() {
    const target = $(this).data("toggle-target");

    return $(this).on("click", function() {
      $(target).toggle();
      return false;
    });
  })
);

