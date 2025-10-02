// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

$(document).on("click", "#competitor_unselect_all", () => select_all_competitors(false));

$(document).on("click", "#competitor_select_all", () => select_all_competitors(true));

var select_all_competitors = function(check_on) {
  $(".registrant_checkbox").each(function() {
    const el = $(this);
    if (el.prop('checked') !== check_on) {
      el.trigger("click");
    }
  });
  return false;
};
// Select the members of this group
// name the comptetitor
// click "create competitor from group"
$(document).on("click", ".reg_group_create", function(e) {
  const el = $(e.target);
  const ids = el.data("registrant-ids");
  const group_name = el.data("groupName");
  select_all_competitors(false);
  select_group_competitors(ids, false);
  enter_group_name(group_name);
  submit_form("reg_create_form");
});

var enter_group_name = function(new_group_name) {
  $("#group_name").each((_, el) => {
    el.value = new_group_name;
  });
}

var submit_form = function(form_class) {
  $("form." + form_class).submit();
}

$(document).on("click", ".reg_group_select", function(e) {
  const el = $(e.target);
  const ids = el.data("registrant-ids");
  select_all_competitors(false);
  select_group_competitors(ids);
});

var select_group_competitors = function(reg_ids, show_alert = true) {
  let count = 0;
  $(".registrant_checkbox").each(function() {
    const el = $(this);
    const reg_id = parseInt(el.val());
    if (reg_ids.includes(reg_id)) {
      el.trigger("click");
      count += 1;
    }
  });
  if (show_alert) {
    alert("selected " + count + " members");
  }
  return false;
};

$(() => new ChosenEnabler($(".chosen-select")));

// Highlights pairs/sets of data which are not all matching
$(() => $(".js--highlightMatching").each(function() {
  const all_children = $(this).find(".js--shouldMatch");
  const first_value = $(all_children[0]).text();
  let all_match = true;
  all_children.each(function() {
    if ($(this).text() !== first_value) {
      all_match = false;
    }
  });
  all_children.each(function() {
    if (all_match) {
      $(this).addClass('matching');
    } else {
      $(this).addClass('unmatching');
    }
  });
}));


$(() => $(".js--hiddenToggleMenu").each(function() {
  $(this).on("click", function() {
    $(".js--hiddenToggle").toggle();
    return false;
  });
}));

$(() => $(".js--shouldNotMatchSet").each(function() {
  const all_children = $(this).find(".js--shouldNotMatch");

  all_children.each(function() {
    let match_count = 0;
    const child_value = $(this).text();
    all_children.each(function() {
      if ($(this).text() === child_value) {
        match_count += 1;
      }
    });
    if (match_count > 1) {
      all_children.each(function() {
        if ($(this).text() === child_value) {
          $(this).addClass('sameValue');
        }
      });
    }
  });
}));


const show_element = target => $(".js--showElement[data-key='" + target + "']").length;

$(() => $(".js--showElementTarget").each(function() {
  const target = $(this);
  if (!show_element(target.data("key"))) {
    target.hide();
  }
}));

$(() => $(".js--highlightIfBlank").each(function() {
  if ($(this).text() === "") {
    $(this).addClass('unmatching');
  }
}));

$(() => $(".js--highlightIfNotBlank").each(function() {
  if ($(this).text() !== "") {
    $(this).addClass('unmatching');
  }
}));

$(() => $(".js--hideElementIfEmpty").each(function() {
  if ($(this).children().size() === 0) {
    $("." + $(this).data("hide-target")).hide();
  }
}));

$(() => $(".js--autoFocus").each(function() {
  $(this).select2('open');
}));
