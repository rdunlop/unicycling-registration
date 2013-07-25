// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require jquery_ujs
//= require_tree .

$(document).ready(function() {
  $(document).on("click", ".banner_remover", function() {
    $("." + $(this).data("banner-class")).remove();
  });
});

$(document).ready(function () {
  if (!$('input').hasClass("multiclick")) {
    $('form').submit(function() {
      $("input[type='submit']", this).attr("disabled", "disabled");
      $("input[type='submit']", this).val("Please wait...");
    });
  }
});

/* Generic sorting dataTable */
$(document).ready(function() {
  $(".sortable").each(function() {
    $(this).dataTable({
      "bInfo": false,
      "bPaginate": false
    });
  });
});
