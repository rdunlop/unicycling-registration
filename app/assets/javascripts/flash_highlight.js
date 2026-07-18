// Replacement for jQuery UI's .effect("highlight") - flashes the element's
// background color, fading back to normal (see common/flash_highlight.scss).
// variant: "green" or "red" (defaults to yellow)
window.flashHighlight = function(el, variant) {
  var $el = $(el);
  var cls = variant ? "flash-highlight--" + variant : "flash-highlight";
  $el.removeClass("flash-highlight flash-highlight--green flash-highlight--red");
  if ($el.length > 0) {
    void $el[0].offsetWidth; // force reflow so a repeat flash restarts the animation
  }
  $el.addClass(cls);
  setTimeout(function() { $el.removeClass(cls); }, 3000);
};
