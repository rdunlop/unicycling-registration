import { Controller } from "@hotwired/stimulus"

// Entries Matching Controller
//
// On the Event Choices page, this enforces a requirement
// that users choose "matching" event_categories
//
// Inputs:
// groups:
//   - This indicates the event_category_id which must all be set together
//   - e.g. [[1, 2, 3], [4, 5]] indicates ids 1,2,3 are a group, and 4,5 are a group
// event_category_element:
//   - This is a select element which must be monitored
//   - If this element value changes, we check ALL other select elements, and if any of them have
//     not-in-this-set values, we display an alert message, AND change the OTHER value
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
    groups: Array
  }

  connect() {
    console.log("Connected EntriesMatchingController")
    console.log(this.groupsValue)
  }

  // Does the current element belong to a group?
  // If so, check to see if any eventCategoryElement
  // is selected to the OTHER values in that group
  // IF they are, change their selection to the correct group value
  // OR to blank
  // AND show an alert
  change(event) {
    console.log("changeD")
    var target = event.target

    // check each group to see if the currently selected value is in a group
    this.groupsValue.forEach((group) => {
      if (group.includes(parseInt(target.value))) {
        // the currently selected value is in this group
        console.log("GROUP CONTAINS VALUE")

        // check all elements
        // And find any which COULD select a value in this set
        // But do not
        this.eventCategoryElementTargets.forEach((entry) => {
          if (entry.value === '') return // isn't selected
          if (entry == target) return // is self
          if (group.includes(parseInt(entry.value))) return // already in the same 'group'

          var entryOptionValues = Array.from(entry.options).map(e => e.value);

          // Does this element have a value which is in the target group?
          var shouldSelect = entryOptionValues.filter( (optionValue) => group.includes(parseInt(optionValue)))
          if (shouldSelect.length != 0) {
            entry.value = shouldSelect[0]
            alert("Changing value")
          }
        })
      }
    })
  }

  // Each select element is automatically configured to trigger
  // the 'change' action if the value is changed
  eventCategoryElementTargetConnected(element) {
    console.log("connecting target")
    element.dataset.action = "entries-matching#change"
  }
}
