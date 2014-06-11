
$(document).ready(function(){
  $('nav > ul > li').mouseover(function() {
    $(this).addClass("hovered");
    var parent_center = $(this).offset().left + ($(this).width() /2);
    var submenu = $(this).find("ul");
    submenu.addClass("hovered");
    var submenu_left = parent_center - (submenu.width()/2);
    if (submenu_left < 0) {
      var width_reduce = ((-submenu_left) * 2);
      submenu.css("max-width", "" + (submenu.width() - width_reduce) + "px");
    }
    submenu.css("left", "" + submenu_left + "px");
    var cur_page = $(".current_page");
    cur_page.addClass("prev_page");
    cur_page.removeClass("current_page");
    var par_page = $(".parent_page");
    par_page.addClass("prev_parent");
    par_page.removeClass("parent_page");
  });
  $('nav > ul > li').mouseout(function() {
    $(this).removeClass("hovered");
    $(this).find("ul").removeClass("hovered");
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
