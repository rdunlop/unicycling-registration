
$(document).ready(function(){
  $('nav > ul > li').click(function(ev) {
    $(".hovered").removeClass("hovered");
    $(this).addClass("hovered");
    var submenu = $(this).find("ul");
    submenu.addClass("hovered");

    // remove the 'current page' if it is selected
    var cur_page = $(".current_page");
    cur_page.addClass("prev_page");
    cur_page.removeClass("current_page");
    var par_page = $(".parent_page");
    par_page.addClass("prev_parent");
    par_page.removeClass("parent_page");
    ev.stopPropagation();
  });
  // click somewhere else
  $('body').click(function() {
    $(".hovered").removeClass("hovered");
    var cur_page = $(".prev_page");
    cur_page.addClass("current_page");
    cur_page.removeClass("prev_page");
    var cur_page = $(".prev_parent");
    cur_page.addClass("parent_page");
    cur_page.removeClass("prev_parent");
  });
});

$(function() {
  links = $("nav").find('a');
  links.each(function() {
    if ($(this).attr('href') == window.location.pathname) {
      $(this).addClass("current_page");
      $(this).closest('li').addClass("current_page");
      $(this).closest('li').parent().closest('li').addClass("parent_page");
    }
  });
});
