/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
this.ChosenEnabler = class ChosenEnabler {
  constructor(selects) {
    this.selects = selects;
    this.selects.select2({
      placeholder: "Select an Option"});
  }
  oldconstructor(selects){
    // enable chosen js
    this.selects = selects;
    return this.selects.chosen({
      allow_single_deselect: true,
      search_contains: true,
      no_results_text: 'No matches',
      width: '200px'
    });
  }
};
