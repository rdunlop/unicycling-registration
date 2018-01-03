$(document).ready(function() {
  $('#lodging_days').on('cocoon:after-insert', function(e, insertedItem) {
    var num_children = insertedItem.parent().children("tr").length;
    if (num_children > 1) {
      var previous_child = $(insertedItem.parent().children("tr")[num_children - 2])
      var previous_value = previous_child.find("input").val();
      var values = previous_value.split("/");
      var new_day = parseInt(values[2]) + 1;
      var new_full_date = values[0] + "/" + values[1] + "/" + new_day;
      $(insertedItem.find("input")[0]).val(new_full_date);
    } else {
      console.log("No previous child");
    }
  });
});
