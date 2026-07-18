// To use this, create a table and add .js--sortable class
// you must also have a data-element on the table with type 'target' which is the URL to post to
// on each individual row, you should have an "item-id" data element, which holds
// the value of the object's id.

const set_js_sortable = function() {
  $('.js--sortable').each(function() {
    const sortable_table = $(this);
    const tbody = sortable_table.find('tbody')[0];
    if (!tbody) return;

    const table_width = sortable_table.width();
    const cells = sortable_table.find('tr')[0].cells.length;
    const desired_width = (table_width / cells) + 'px';
    sortable_table.find('td').css('width', desired_width);

    Sortable.create(tbody, {
      direction: 'vertical',
      draggable: '.item',

      onStart(evt) {
        $(evt.item).addClass('active-item-shadow');
      },
      onEnd(evt) {
        const item = $(evt.item);
        item.removeClass('active-item-shadow');
        // highlight the row on drop to indicate an update
        flashHighlight(item);

        if (evt.newIndex === evt.oldIndex) return; // order unchanged

        const item_id = item.data('item-id');
        const position = evt.newIndex; // this will not work with paginated items, as the index is zero on every page
        $.ajax({
          type: 'POST',
          url: sortable_table.data('target'),
          dataType: 'json',
          data: { id: item_id, row_order_position: position },
          complete: request => {
            if (request.status === 200) {
              eval(request.responseText);
            }
          }
        });
      }
    });
  });
};

$(() => set_js_sortable());

// called from .js.erb responses, which execute in global scope
window.set_js_sortable = set_js_sortable;
