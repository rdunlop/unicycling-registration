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
//= require dataTables/jquery.dataTables
//= require dataTables/jquery.dataTables.foundation
//= require jquery-ui/sortable
//= require jquery-ui/tabs
//= require jquery-ui/tooltip
//= require jquery-ui/effect-blind
//= require jquery-ui/effect-drop
//= require jquery-ui/effect-fade
//= require jquery-ui/effect-highlight
//= require jquery-ui/effect-slide
//= require foundation
//= require select2
//= require select2_locale_fr
//= require select2_locale_de
//= require select2_locale_hu
//= require select2_locale_es
//= require select2_locale_ko
//= require select2_locale_ja
// NOTE: not available select2_locale_ja
//= require fancybox
//= require cocoon
//= require jquery.are-you-sure
//= require jquery.datetimepicker

//= require attending
//= require block_displayer
//= require block_enabler_by_radio
//= require block_visible
//= require block_visible_based_on_select
//= require chosen_enabler
//= require competitors
//= require date_picker
//= require event_choice_creation_manager
//= require fancybox_enabler
//= require input_enabler
//= require jquery.are-you-sure
//= require jquery.placeholder
//= require lane_assignment
//= require payments
//= require registrants
//= require reorder_rows
//= require total_calculator
//= require total_cost
//= require usa_member_refresher
//= require visibility_toggler

// NOTE This file does NOT include wysiwyg.js

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
    $(this).on('cocoon:after-insert', function(e, added_item) {
      init_new_row(added_item)
    });
  });
});


// Sorting the list

var get_sortable_string = function() {
  additional = "";
  if ($('.drag_drop_sortable').data('additional')) {
    additional = $("#" + $('.drag_drop_sortable').data('additional')).serialize();
    if (additional !== "") {
      additional = "&" + additional;
    }
  }

  return $('.drag_drop_sortable').sortable('serialize') + additional;
};

var set_sortable = function() {
  // jQuery UI Sortable
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
        url: $('.drag_drop_sortable').data('target')});
    }
  }).disableSelection();
};
$(document).ready(function(){
  set_sortable();
});


$(function() {
  $(".not_qualified").each(function() {
    $(this).attr('title', 'Not Qualified');
  });
});

$(function(){ $(document).foundation(); });
