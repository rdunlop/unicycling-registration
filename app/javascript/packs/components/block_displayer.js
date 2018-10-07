/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
// Display Blocks when a checkbox/radio is checked
// usage:
//  checkbox/radio element:
//    class: 'js--displayIfChecked'
//    data: 'displayblock' - the class of the target elements
//
// target element:
//    class: class matching the displayblock class

this.BlockDisplayer = class BlockDisplayer {

  constructor(radioElements) {
    this.radioElements = radioElements;
    this.bindSources();
    this.displayHideAll();
  }

  bindSources() {
    return this.radioElements.on("change", () => {
      return this.displayHideAll();
    });
  }

  displayHideAll() {
    return this.radioElements.each((_, el) => {
      return this.displayHide($(el));
    });
  }

  displayHide(radioElement) {
    const blockElement = $(`.${$(radioElement).data("displayblock")}`);
    if (radioElement.prop("checked")) {
      return blockElement.show();
    } else {
      return blockElement.hide();
    }
  }
};

$(() => new BlockDisplayer($(".js--displayIfChecked")));
