/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
// Enable Elements when a radio button is checked
// Also visually adjust the displays
//
// usage:
//  radio element:
//    class: 'js--disableByRadio'
//    data: 'disable_wrapper' - the class of the area to disable when selected
//    data: 'enable_wrapper' - the class of the area to enable when selected

this.BlockEnablerByRadio = class BlockEnablerByRadio {

  constructor(radio){
    this.radio = radio;
    this.bindSource();
    this.enableDisable();
  }

  enableTargetClass() {
    return this.radio.data("enable-wrapper");
  }

  disableTargetClass() {
    return this.radio.data("disable-wrapper");
  }

  enableTargetElements() {
    return $(`.${this.enableTargetClass()}`);
  }

  disableTargetElements() {
    return $(`.${this.disableTargetClass()}`);
  }

  bindSource() {
    return this.radio.on("change", () => {
      return this.enableDisable();
    });
  }

  // Initial setup
  enableDisable() {
    if (this.radio.prop("checked")) {
      this.enableElements(this.enableTargetElements());
      this.disableElements(this.disableTargetElements());

      this.enableInputs(this.enableTargetElements());
      return this.disableInputs(this.disableTargetElements());
    }
  }

  enableElements(elements) {
    return elements.each(function() {
      return $(this).removeClass("copy_choice--disabled");
    });
  }

  disableElements(elements) {
    return elements.each(function() {
      return $(this).addClass("copy_choice--disabled");
    });
  }

  enableInputs(elements) {
    return elements.find("input, select").each(function() {
      return $(this).attr("disabled", false);
    });
  }

  disableInputs(elements) {
    return elements.find("input, select").each(function() {
      return $(this).attr("disabled", true);
    });
  }
};

$(() =>
  $(".js--disableByRadio").each((_, element) => new BlockEnablerByRadio($(element)))
);
