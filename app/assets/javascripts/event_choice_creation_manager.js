// Display Blocks when a checkbox/radio is checked
// usage:
//  checkbox/radio element:
//    class: 'js--displayIfChecked'
//    data: 'displayblock' - the class of the target elements
//
// target element:
//    class: class matching the displayblock class

this.EventChoiceCreationManager = class EventChoiceCreationManager {

  constructor(form) {
    this.form = form;
    this.bindSources();
    this.updateDisabledElements();
  }

  bindSources() {
    this.form.on("change", "#event_choice_cell_type", () => {
      this.updateDisabledElements();
    });
  }

  updateDisabledElements() {
    switch ($("#event_choice_cell_type").val()) {
      case "boolean":
        this.disableElements(true, true, true, true);
      case "multiple":
        this.disableElements(false, false, false, false);
      case "text": case "best_time":
        this.disableElements(true, false, false, false);
      default:
        this.disableElements(false, false, false, false);
    }
  }

  disableElements(multiple, optional, optional_if, required_if) {
    $("#event_choice_multiple_values").attr("disabled", multiple);
    $("#event_choice_optional").attr("disabled", optional);
    $("#event_choice_optional_if_event_choice_id").attr("disabled", optional_if);
    $("#event_choice_required_if_event_choice_id").attr("disabled", required_if);
  }
};

$(() => new EventChoiceCreationManager($(".js--eventChoiceForm")));
