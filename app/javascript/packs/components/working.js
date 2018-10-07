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
