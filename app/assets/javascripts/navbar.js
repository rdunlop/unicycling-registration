
$(document).ready(function(){
  $('nav > ul > li').each( function() {
    window_size = $(document).width();
    curr_position = $(this).offset().left;

    target = $(this).find("ul");
    max_width = 800;
    if (curr_position + max_width > window_size) {
      $(target).css("padding-left", "" + (window_size - max_width) + "px");
    } else {
      $(target).css("padding-left", "" + curr_position + "px");
    }
    //$(this).css("left", "120px");
    $(target).css("max-width", "" +max_width + "px");
  });
});
