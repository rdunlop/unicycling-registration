class ChosenEnabler {
  constructor(selects) {
    this.selects = selects;
    this.selects.select2({
      placeholder: "Select an Option"});
  }
  oldconstructor(selects){
    // enable chosen js
    this.selects = selects;
    this.selects.chosen({
      allow_single_deselect: true,
      search_contains: true,
      no_results_text: 'No matches',
      width: '200px'
    });
  }
};

export { ChosenEnabler };
