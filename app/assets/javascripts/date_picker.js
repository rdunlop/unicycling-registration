$(function() {
  var create_date_picker = function(el) {
    var options = {
      timepicker: false,
      format: "Y/m/d",
      scrollMonth: false,
      scrollTime: false,
      scrollInput: false,
      defaultDate: ''
    };
    if ($(el).data("min-date").length > 0) {
      options["minDate"] = $(el).data("min-date")
      options["startDate"] = options["minDate"]
    }

    if ($(el).data("max-date").length > 0) {
      options["maxDate"] = $(el).data("max-date")
    }

    $(el).datetimepicker(options);
  };

  // this needs to be in a loop or else the pickers don't work well on the Important Dates page
  $(".datepicker").each((_, el) => {
    create_date_picker(el);
  });

  $('.datetimepicker').datetimepicker();

  $(document).on("cocoon:after-insert", (e, insertedItem) => {
    $(insertedItem).find(".datepicker").each((_, el) => {
      create_date_picker(el);
    });
  });
});
