/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
// You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$(document).on("click", "#competitor_unselect_all", () => select_all_competitors(false));

$(document).on("click", "#competitor_select_all", () => select_all_competitors(true));

var select_all_competitors = function(check_on) {
  $(".registrant_checkbox").each(function() {
    const el = $(this);
    if (el.prop('checked') !== check_on) {
      return el.trigger("click");
    }
  });
  return false;
};

$(document).on("click", ".reg_group_select", function(e) {
  const el = $(e.target);
  const ids = el.data("registrant-ids");
  select_all_competitors(false);
  return select_group_competitors(ids);
});

var select_group_competitors = function(reg_ids) {
  let count = 0;
  $(".registrant_checkbox").each(function() {
    const el = $(this);
    const reg_id = parseInt(el.val());
    if (reg_ids.includes(reg_id)) {
      el.trigger("click");
      return count += 1;
    }
  });
  alert(`selected ${count} members`);
  return false;
};

$(() => new ChosenEnabler($(".chosen-select")));

// Highlights pairs/sets of data which are not all matching
$(() =>
  $(".js--highlightMatching").each(function() {
    const all_children = $(this).find(".js--shouldMatch");
    const first_value = $(all_children[0]).text();
    let all_match = true;
    all_children.each(function() {
      if ($(this).text() !== first_value) {
        return all_match = false;
      }
    });
    return all_children.each(function() {
      if (all_match) {
        return $(this).addClass('matching');
      } else {
        return $(this).addClass('unmatching');
      }
    });
  })
);


$(() =>
  $(".js--hiddenToggleMenu").each(function() {
    return $(this).on("click", function() {
      $(".js--hiddenToggle").toggle();
      return false;
    });
  })
);

$(() =>
  $(".js--shouldNotMatchSet").each(function() {
    const all_children = $(this).find(".js--shouldNotMatch");

    return all_children.each(function() {
      let match_count = 0;
      const child_value = $(this).text();
      all_children.each(function() {
        if ($(this).text() === child_value) {
          return match_count += 1;
        }
      });
      if (match_count > 1) {
        return all_children.each(function() {
          if ($(this).text() === child_value) {
            return $(this).addClass('sameValue');
          }
        });
      }
    });
  })
);


const show_element = target => $(`.js--showElement[data-key='${target}']`).length;

$(() =>
  $(".js--showElementTarget").each(function() {
    const target = $(this);
    if (!show_element(target.data("key"))) {
      return target.hide();
    }
  })
);

$(() =>
  $(".js--highlightIfBlank").each(function() {
    if ($(this).text() === "") {
      return $(this).addClass('unmatching');
    }
  })
);

$(() =>
  $(".js--highlightIfNotBlank").each(function() {
    if ($(this).text() !== "") {
      return $(this).addClass('unmatching');
    }
  })
);

$(() =>
  $(".js--hideElementIfEmpty").each(function() {
    if ($(this).children().size() === 0) {
      return $(`.${$(this).data("hide-target")}`).hide();
    }
  })
);

$(() =>
    $(".js--autoFocus").each(function() {
      return $(this).select2('open');
    })
);
