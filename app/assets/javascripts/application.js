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
//= require chosen-jquery
//= require fancybox
//= require jquery.nested-fields
//= require_tree .

$(document).ready(function() {
  $(document).on("click", ".banner_remover", function() {
    $("." + $(this).data("banner-class")).remove();
    return false;
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
    if ($(this).hasClass('searchable')) {
       search = true;
    } else {
       search = false;
    }
   $(this).DataTable({
     "bFilter": search,
     "bInfo": false,
     "bPaginate": false,
     "autoWidth": false,
     "orderClasses": false
   });
  });
});

/* Blatantly stoles from competitor.js.coffee */
var enable_chosen = function() {
  $('.chosen-select').chosen({
    allow_single_deselect: true,
    search_contains: true,
    no_results_text: 'No matches',
    width: '200px'});
};

$(document).ready(function(e) {
  $('FORM').each(function() {
    if ($(this).hasClass('multiple_nested')) {
      $('.nested_nested').nestedFields({
        afterInsert: function(item) {
          enable_chosen();
        }
      });
    }
    else
    {
      $(this).nestedFields({
        afterInsert: function(item) {
          enable_chosen();
        }
     });
    }
  });
});


// Sorting the list

var get_sortable_string = function() {
  additional = ""
  if ($('.drag_drop_sortable').data('additional')) {
    additional = $("#" + $('.drag_drop_sortable').data('additional')).serialize()
    if (additional != "") {
      additional = "&" + additional
    }
  }

  return $('.drag_drop_sortable').sortable('serialize') + additional
}

var set_sortable = function() {
  $('.drag_drop_sortable').sortable({
    axis: 'y',
    dropOnEmpty: false,
    //handle: '.handle',
    cursor: 'crosshair',
    items: 'tr',
    opacity: 0.4,
    scroll: true,
    update: function(){
      $.ajax({
        type: 'post',
        data: get_sortable_string(),
        dataType: 'script',
        complete: function(request){
          $('.drag_drop_sortable').effect('highlight');
        },
        url: $('.drag_drop_sortable').data('target')})
    }
  }).disableSelection();
}
$(document).ready(function(){
  set_sortable();
});


$(function() {
  $(".not_qualified").each(function() {
    $(this).attr('title', 'Not Qualified');
  });
});
