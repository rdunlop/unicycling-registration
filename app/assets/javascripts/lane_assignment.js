/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS205: Consider reworking code to avoid use of IIFEs
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
$(() => $(".js--shrinkToFit").each(function() {
  const t = $(this);
  while (this.scrollWidth > this.offsetWidth) {
    var current_font_size = parseFloat(t.css("font-size"));
    var new_font_size = (current_font_size - 1) + "px";
    t.css("font-size", new_font_size);
  }
}));
