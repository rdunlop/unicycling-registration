/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS205: Consider reworking code to avoid use of IIFEs
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
$(() =>
  $(".js--shrinkToFit").each(function() {
    const t = $(this);
    return (() => {
      const result = [];
      while (this.scrollWidth > this.offsetWidth) {
        const current_font_size = parseFloat(t.css("font-size"));
        const new_font_size = (current_font_size - 1) + "px";
        result.push(t.css("font-size", new_font_size));
      }
      return result;
    })();
  })
);
