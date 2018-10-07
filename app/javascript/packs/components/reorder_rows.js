/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * DS208: Avoid top-level this
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
// To use this, create a table and add .js--sortable class
// you must also have a data-element on the table with type 'target' which is the URL to post to
// on each individual row, you should have an "item-id" data element, which holds
// the value of the object's id.

var exports = exports != null ? exports : this;

const set_js_sortable = function() {
  const sortable_table = $('.js--sortable');
  if (sortable_table.length > 0) {
    const table_width = sortable_table.width();
    const cells = sortable_table.find('tr')[0].cells.length;
    const desired_width = (table_width / cells) + 'px';
    sortable_table.find('td').css('width', desired_width);

    // jQuery Sortable
    return sortable_table.sortable({
      axis: 'y',
      items: '.item',
      cursor: 'move',

      sort(e, ui) {
        return ui.item.addClass('active-item-shadow');
      },
      stop(e, ui) {
        ui.item.removeClass('active-item-shadow');
        // highlight the row on drop to indicate an update
        return ui.item.children('td').effect('highlight', {}, 1000);
      },
      update(e, ui) {
        const item_id = ui.item.data('item-id');
        const position = ui.item.index(); // this will not work with paginated items, as the index is zero on every page
        return $.ajax({
          type: 'POST',
          url: sortable_table.data('target'),
          dataType: 'json',
          data: { id: item_id, row_order_position: position },
          complete: request => {
            if (request.status === 200) {
              return eval(request.responseText);
            }
          }
        });
      }
    });
  }
};

$(() => set_js_sortable());

exports.set_js_sortable = set_js_sortable;
