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
    this.radioElements.on("change", () => {
      this.displayHideAll();
    });
  }

  displayHideAll() {
    this.radioElements.each((_, el) => {
      this.displayHide($(el));
    });
  }

  displayHide(radioElement) {
    const blockElement = $("." + $(radioElement).data("displayblock"));
    if (radioElement.prop("checked")) {
      blockElement.show();
    } else {
      blockElement.hide();
    }
  }
};

$(() => new BlockDisplayer($(".js--displayIfChecked")));
