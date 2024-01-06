import { Controller } from "@hotwired/stimulus"

// Pronouns Gender selection Controller
//
// On the Registrant Base Details page, this auto-selects the Competitive Gender
// based on the pronouns selected. But only if there isn't a competitive gender selected
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

  // If the user has selected a pronoun
  // And no gender is currently selected
  // and the selected pronoun has a gender_value
  // auto-select the gender radio button
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
