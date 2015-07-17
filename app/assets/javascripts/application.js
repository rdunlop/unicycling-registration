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
//= require foundation
//= require chosen-jquery
//= require fancybox
//= require jquery.nested-fields
//= require jquery.are-you-sure
//= require tinymce
//= require jquery.datetimepicker
//= require_tree .

$(document).ready(function () {
  if (!$('input').hasClass("multiclick")) {
    $('form').submit(function() {
      $("input[type='submit']", this).attr("disabled", "disabled");
      $("input[type='submit']", this).val("Please wait...");
    });
  }
});

$(document).ready(function() {
  // this conflicts with using a password manager on the log-in page
  $('form').not(".no_dirty_check").areYouSure();
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

$(document).ready(function(e) {
  var init_new_row = function(item) {
    new ChosenEnabler($(item).find(".chosen-select"));
    $(item).find("input[autofocus='autofocus']").focus();
  };

  $('FORM').each(function() {
    if ($(this).hasClass('multiple_nested')) {
      $('.nested_nested').nestedFields({
        afterInsert: init_new_row
      });
    }
    else
    {
      $(this).nestedFields({
        afterInsert: init_new_row
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

$(function(){ $(document).foundation(); });
