$(function() {
  const create_date_picker = el => $(el).datetimepicker({
    timepicker: false,
    format: "Y/m/d",
    scrollMonth: false,
    scrollTime: false,
    scrollInput: false,
    defaultDate: ''
  });

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
