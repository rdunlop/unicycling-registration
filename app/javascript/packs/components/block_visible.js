/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
$(function() {
  if ($(".js--blockVisibleSource").length > 0) {
    return new BlockVisibleBasedOnSelect($(".js--blockVisibleSource"), $(".js--blockVisibleTarget"), "is--hidden");
  }
});
