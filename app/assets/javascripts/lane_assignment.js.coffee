$ ->
  $(".js--shrinkToFit").each ->
    t = $(this)
    while (this.scrollWidth > this.offsetWidth)
      current_font_size = parseFloat(t.css("font-size"));
      new_font_size = (current_font_size - 1) + "px"
      t.css("font-size", new_font_size)
