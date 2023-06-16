// Calculate the total amount of money from multiple fields
// usage:
//  checkbox element:
//    class: 'js--costItem'
//    data: 'cents' - the cost (in cents) to add if this checkbox is checked
//
// totalDisplay:
//    class: (js--total) - class of the field in which to write the total

this.TotalCalculator = class TotalCalculator {

  constructor(checkboxElement, totalDisplay) {
    this.checkboxElement = checkboxElement;
    this.totalDisplay = totalDisplay;
    this.bindSources();
    this.calculateTotal();
  }

  bindSources() {
    this.checkboxElement.on("change", () => {
      this.calculateTotal();
    });
  }

  calculateTotal() {
    let total_cents = 0;
    this.checkboxElement.each(function() {
      if ($(this).prop('checked')) {
        total_cents += parseInt($(this).data("cents"));
      }
    });
    const total = (total_cents / 100).toFixed(2);
    this.totalDisplay.html(total);
  }
};

$(() => new TotalCalculator($(".js--costItem"), $(".js--total")));
