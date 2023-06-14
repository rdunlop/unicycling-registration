import { Controller } from "@hotwired/stimulus"

// Entries Matching Controller
//
// On the Event Choices page, this enforces a requirement
// that users choose "matching" event_categories
//
// Inputs:
// groups-value:
//   - This indicates the event_category_id which must all be set together
//   - e.g. [[1, 2, 3], [4, 5]] indicates ids 1,2,3 are a group, and 4,5 are a group
// event_category_element:
//   - This is a select element which must be monitored
//   - If this element value changes, we check ALL other select elements, and if any of them have
//     not-in-this-set values, we display an alert message, AND change the OTHER value
// change-message-value:
//   - This is a text message which will be presented when the javascript chooses to change a user's selection
// clear-message-value:
//   - This is a text message which will be presented when the javascript chooses to clear a user's selection
//
// Example usage:
// <div data-controller="entries-matching" data-entries-matching-groups-value="[[1,2,3],[4,5]]">
//   <select data-entries-matching-target="eventCategoryElement">
//     <option>
//     <option value="1">
//     <option value="4">
//   </select>
//
//   <select data-entries-matching-target="eventCategoryElement">
//     <option>
//     <option value="2">
//     <option value="5">
//   </select>
//
//   <select data-entries-matching-target="eventCategoryElement">
//     <option>
//     <option value="3">
//   </select>
// </div>
export default class extends Controller {

  static targets = ["eventCategoryElement"]
  static values = {
    groups: Array,
    clearMessage: String,
    changeMessage: String
  }

  connect() {
    if (this.clearMessageValue == '') {
      this.clearMessageValue = "You must choose similar categories for your events. We have cleared one of your choices...please re-choose the appropriate category"
    }
    if (this.changeMessageValue == '') {
      this.changeMessageValue = "You must compete in the same category in these events. We have updated your other event category to match"
    }
  }

  // Does the current element belong to a group?
  // If so, check to see if any eventCategoryElement
  // is selected to the OTHER values in that group
  // IF they are, change their selection to the correct group value
  // OR to blank
  // AND show an alert
  change(event) {
    var target = event.target

    // check all elements to see if they need to change
    // THIS CODE mirror's what's in categories_validator.rb
    this.eventCategoryElementTargets.forEach((entry) => {
      if (entry.value === '') return // isn't selected
      if (entry == target) return // is self

      // check each group to see if the currently selected value is in a group
      var acceptableElementValues = this.groupsValue.filter( (group) => group.includes(parseInt(target.value))).flat()

      if (acceptableElementValues.length == 0) return // current selected value isn't in a grouping
      if (acceptableElementValues.includes(parseInt(entry.value))) return
      // the currently selected value is in this group

      var entryOptionValues = Array.from(entry.options).map(e => e.value);

      // Does this element have a value which is in the target group?
      var shouldSelect = entryOptionValues.filter( (optionValue) => acceptableElementValues.includes(parseInt(optionValue)))
      if (shouldSelect.length == 0) return
      if (shouldSelect.length == 1) {
        entry.value = shouldSelect[0]
        alert(this.changeMessageValue)
      }
      if (shouldSelect.length > 1) {
        entry.value = ''
        alert(this.clearMessageValue)
      }
    })
  }

  // Each select element is automatically configured to trigger
  // the 'change' action if the value is changed
  eventCategoryElementTargetConnected(element) {
    element.dataset.action = "entries-matching#change"
  }
}
