var new_row = $("<%= escape_javascript(render partial: 'member_row', object: @registrant) %>")
old_row = $("#reg_<%= @registrant.id %>")
old_row.replaceWith(new_row)
new_row.effect("highlight", {}, 3000);
