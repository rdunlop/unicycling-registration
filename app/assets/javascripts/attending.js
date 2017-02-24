$(document).ready(function() {
  // Hide the tabs until the page is ready to be styled.
  var el = $("#tabs");
  var active_tab = el.data("active") || 0;
  $( "#tabs" )
    .show()
    .tabs({ heightStyle: "auto", active: active_tab});
});

$(document).on("click", ".primary_checkbox", function() {
  el = $(this);
  if (!el.prop('checked')) {
    // unselect all options
    row = el.closest("div[class='event_choices']");
    selects = row.find("select");
    selects.each(function() {
      sel = $(this);
      sel.val("");
    });
    checkbox_inputs = row.find("input[type='checkbox']");
    checkbox_inputs.each(function() {
      inp = $(this);
      inp.prop('checked', false);
    });
    text_inputs = row.find("input[type='text']");
    text_inputs.each(function() {
      inp = $(this);
      inp.val("");
    });
  }
});

$(document).ready(function() {
  $(".disabled_event input, .disabled_event select").each(function() {
    $(this)[0].disabled = "disabled"; // This is where I'm trying to disable the input buttons
  });
});
