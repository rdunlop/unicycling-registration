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
//= require sortablejs
//= require foundation
//= require select2
//= require select2_locale_fr
//= require select2_locale_de
//= require select2_locale_hu
//= require select2_locale_es
//= require select2_locale_ko
//= require select2_locale_ja
//= require select2_locale_it
//= require select2_locale_da
//= require select2_locale_nl
// NOTE: not available select2_locale_ja
//= require fancybox
//= require cocoon
//= require jquery.are-you-sure
//= require datetimepicker

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
//= require flash_highlight
//= require input_enabler
//= require jquery.are-you-sure
//= require jquery.placeholder
//= require lane_assignment
//= require lodging_adder
//= require payments
//= require registrants
//= require reorder_rows
//= require total_calculator
//= require total_cost
//= require organization_member_refresher
//= require visibility_toggler

// NOTE This file does NOT include wysiwyg.js

$(document).ready(function() {
  // this conflicts with using a password manager on the log-in page
  $('form').not(".no_dirty_check").areYouSure();
});

/* Generic sorting dataTable */
$(document).ready(function() {
  $(".sortable").each(function() {
    let search = false;
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
  var sortable = $('.drag_drop_sortable');

  // matches jQuery UI's .sortable('serialize'): row id "age_group_entry_123" -> "age_group_entry[]=123"
  var parts = sortable.find('tr[id]').map(function() {
    var match = this.id.match(/^(.+)_(\d+)$/);
    return match ? match[1] + '[]=' + match[2] : null;
  }).get();

  var additional = "";
  if (sortable.data('additional')) {
    additional = $("#" + sortable.data('additional')).serialize();
    if (additional !== "") {
      additional = "&" + additional;
    }
  }

  return parts.join('&') + additional;
};

var set_sortable = function() {
  $('.drag_drop_sortable').each(function() {
    Sortable.create(this, {
      direction: 'vertical',
      draggable: 'tr',
      onEnd: function(evt){
        if (evt.newIndex === evt.oldIndex) return; // order unchanged

        $.ajax({
          type: 'post',
          data: get_sortable_string(),
          dataType: 'script',
          complete: function(request){
            flashHighlight($('.drag_drop_sortable'));
          },
          url: $('.drag_drop_sortable').data('target')});
      }
    });
  });
};
$(document).ready(function(){
  set_sortable();
});

// called from .js.erb responses, which execute in global scope
window.set_sortable = set_sortable;


$(function() {
  $(".not_qualified").each(function() {
    $(this).attr('title', 'Not Qualified');
  });
});

$(function(){ $(document).foundation(); });
