/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
// Enable Elements when a checkbox is checked
// usage:
//  checkbox element:
//    class: 'js--inputEnable'
//    data: 'targets' - the class of the target elements
//
// target element:
//    class: class matching the targets class

this.InputEnabler = class InputEnabler {

  constructor(checkbox){
    this.checkbox = checkbox;
    this.bindSource();
    this.enableDisable();
  }

  targetClass() {
    return this.checkbox.data("targets");
  }

  targetElements() {
    return $(`.${this.targetClass()}`);
  }

  bindSource() {
    return this.checkbox.on("change", () => {
      return this.enableDisable();
    });
  }

  enableDisable() {
    if (this.checkbox.prop("checked")) {
      return this.targetElements().each(function() {
        return $(this).attr("disabled", false);
      });
    } else {
      return this.targetElements().each(function() {
        $(this).val("");
        return $(this).attr("disabled", true);
      });
    }
  }
};

$(() =>
  $(".js--inputEnable").each((_, element) => new InputEnabler($(element)))
);
