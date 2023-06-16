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
    this.checkbox.on("change", () => {
      this.enableDisable();
    });
  }

  enableDisable() {
    if (this.checkbox.prop("checked")) {
      this.targetElements().each(function() {
        $(this).attr("disabled", false);
      });
    } else {
      this.targetElements().each(function() {
        $(this).val("");
        $(this).attr("disabled", true);
      });
    }
  }
};

$(() => $(".js--inputEnable").each((_, element) => new InputEnabler($(element))));
