/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
// Total up the floats in each of the elements
// usage:
//  target element:
//    data: 'cost-total-ancestor' - the class of the an ancestor, from which to search for the data-cost-elements
//
// source element:
//    data: cost-element (set this attribute to true)

this.TotalCostDisplayer = class TotalCostDisplayer {

  constructor(target){
    this.target = target;
    this.recalculateTotal();
  }

  sourceClass() {
    return this.target.data("cost-total-ancestor");
  }

  sourceElements() {
    return $(this.ancestorElement()).find("[data-cost-element]");
  }

  ancestorElement() {
    return this.target.closest(this.target.data("cost-total-ancestor"));
  }

  recalculateTotal() {
    let total = 0;
    this.sourceElements().each(function() {
      return total += parseFloat($(this).val());
    });
    return this.target.val(total);
  }
};

$(function() {
  $(document).on('change', '[data-cost-element]', element => {
    return $('[data-cost-total-ancestor]').each(function() {
      return new TotalCostDisplayer($(this));
    });
  });

  // initial load
  return $('[data-cost-total-ancestor]').each(function() {
    return new TotalCostDisplayer($(this));
  });
});
