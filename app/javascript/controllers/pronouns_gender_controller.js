import { Controller } from "@hotwired/stimulus"

// Pronouns Gender selection Controller
//
// On the Registrant Base Details page, this auto-selects the Competitive Gender
// based on the pronouns selected. But only if there isn't a competitive gender selected
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
// <div data-controller="pronouns-gender" data-pronouns-gender-gender-element-name-value="gender-input">
//   <input type='radio' data-pronouns-gender-target='pronounElement' data-pronouns-gender-value='Female'>She/her
//   <input type='radio' data-pronouns-gender-target='pronounElement'>They/them
//   <input type='radio' data-pronouns-gender-target='pronounElement' data-pronouns-gender-value='Male'>He/him
//   <input type='radio' data-pronouns-gender-target='pronounElement'>Other
//
//   Competitive Gender:
//   <input type='radio' name='gender-input' data-pronouns-gender-target='genderElement' data-pronouns-gender-value='Male'>Male
//   <input type='radio' name='gender-input' data-pronouns-gender-target='genderElement' data-pronouns-gender-value='Female'>Female
// </div>
export default class extends Controller {

  static targets = ["pronounElement"]

  static values = { genderElementName: String }

  // Does the current element belong to a group?
  // If so, check to see if any eventCategoryElement
  // is selected to the OTHER values in that group
  // IF they are, change their selection to the correct group value
  // OR to blank
  // AND show an alert
  change(event) {
    var target = event.target

    if (this.genderSelected()) { return }

    console.log(target.dataset);

    if (target.dataset["pronounsGenderValue"] == undefined) { return }

    this.selectGender(target.dataset["pronounsGenderValue"]);
  }

  selectGender(newGender) {
    var genderElements = document.getElementsByName(this.genderElementNameValue)
    if (genderElements.length == 0) { return true }

    genderElements.forEach((genderElement) => {
      if (genderElement.value == newGender) {
        genderElement.checked = true;
        return;
      }
    })
  }

  genderSelected() {
    var genderElements = document.getElementsByName(this.genderElementNameValue)
    if (genderElements.length == 0) { return true }

    var result = false;

    genderElements.forEach((genderElement) => {
      if (genderElement.checked) {
        result = true;
      }
    })

    return result;
  }

  // Each select element is automatically configured to trigger
  // the 'change' action if the value is changed
  pronounElementTargetConnected(element) {
    element.dataset.action = "pronouns-gender#change"
  }
}
