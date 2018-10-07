/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
$(function() {
  const create_date_picker = el =>
    $(el).datetimepicker({
      timepicker: false,
      format: "Y/m/d",
      scrollMonth: false,
      scrollTime: false,
      scrollInput: false,
      defaultDate: '<%= EventConfiguration.singleton.start_date.try(:strftime, "%Y/%m/%d") %>'
    })
  ;

  // this needs to be in a loop or else the pickers don't work well on the Important Dates page
  $(".datepicker").each((_, el) => {
    return create_date_picker(el);
  });

  $('.datetimepicker').datetimepicker();

  return $(document).on("cocoon:after-insert", (e, insertedItem) => {
    return $(insertedItem).find(".datepicker").each((_, el) => {
      return create_date_picker(el);
    });
  });
});
