class BlockVisibleBasedOnSelect {
  constructor($select_element, $target_elements, hiddenClass) {
    this._toggleVisibility = this._toggleVisibility.bind(this);
    this._currentValue = this._currentValue.bind(this);
    this.$select_element = $select_element;
    this.$target_elements = $target_elements;
    if (hiddenClass == null) { hiddenClass = "is--hidden"; }
    this.hiddenClass = hiddenClass;
    this.$select_element.on("change", this._toggleVisibility);
    this._toggleVisibility();
  }

  _toggleVisibility() {
    $.each(this.$target_elements, (_index, element) => {
      const $el = $(element);
      if (this._currentValue() === null) {
        $el.removeClass(this.hiddenClass);
        return;
      }

      if ($el.data("show")) {
        // show this element only if it should be shown
        // the data element may be an array, which would be comma-delimited
        if ($el.data("show").indexOf(this._currentValue()) >= 0) {
          $el.removeClass(this.hiddenClass);
        } else {
          $el.addClass(this.hiddenClass);
        }
      }
    });
  }

  _currentValue() {
    if (this.$select_element.val() === "") {
      return null;
    } else {
      return this.$select_element.val();
    }
  }
}


export { BlockVisibleBasedOnSelect };
