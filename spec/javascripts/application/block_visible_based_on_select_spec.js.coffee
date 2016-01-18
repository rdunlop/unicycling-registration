# Show/hide a block of content based on the specific value of a select box
#
# Example Usage:
# <select class="js--blockVisibleSource">
#  <option value="one">1</option>
#  <option value="two">2</option>
#  <option value="three">3</option>
# </select>
#
# <div class="js--blockVisibleTarget" data-show="['one', 'two']">
#   Some Content shown for nil/1/2
# </div>
#
# <div class="js--blockVisibleTarget" data-hide="['three']" >
#   Some content shown for nil/1/2
# </div>
#
# javascript:
#   new BlockVisibleBasedOnSelect($(".js--blockVisibleSource"), $(".js--blockVisibleTarget"), "is--hidden")
#
describe "BlockVisibleBasedOnSelect", ->
  beforeEach ->
    @selectInput = affix("select.js--blockVisibleSource")
    @defaultOption = @selectInput.affix("option")
    @firstOption = @selectInput.affix("option")
      .attr("value", "one")
    @secondOption = @selectInput.affix("option")
      .attr("value", "two")

  describe "when a show block exists", ->
    beforeEach ->
      @block_one = affix("div.js--blockVisibleTarget")
        .attr("data-show", "['one']")
      @block_two = affix("div.js--blockVisibleTarget")
        .attr("data-show", "['two']")

      new BlockVisibleBasedOnSelect(
        $(".js--blockVisibleSource"),
        $(".js--blockVisibleTarget"),
        "is--hidden")

    it "shows all blocks by default", ->
      expect(@block_one).not.toHaveClass("is--hidden")
      expect(@block_two).not.toHaveClass("is--hidden")

    describe "when the select box has chosen 'one'", ->
      beforeEach ->
        @firstOption.prop("selected", true)
        @selectInput.trigger("change")

      it "shows block one", ->
        expect(@block_one).not.toHaveClass("is--hidden")

      it "does not show block two", ->
        expect(@block_two).toHaveClass("is--hidden")

    describe "when a show block with 2 keys exists", ->
      beforeEach ->
        @block_one = affix("div.js--blockVisibleTarget")
          .attr("data-show", "['one', 'two']")
        @block_two = affix("div.js--blockVisibleTarget")
          .attr("data-show", "['two', 'three']")

        new BlockVisibleBasedOnSelect(
          $(".js--blockVisibleSource"),
          $(".js--blockVisibleTarget"),
          "is--hidden")

      it "shows all blocks by default", ->
        expect(@block_one).not.toHaveClass("is--hidden")
        expect(@block_two).not.toHaveClass("is--hidden")

      describe "when the select box has chosen 'one'", ->
        beforeEach ->
          @firstOption.prop("selected", true)
          @selectInput.trigger("change")

        it "shows block one", ->
          expect(@block_one).not.toHaveClass("is--hidden")

        it "does not show block two", ->
          expect(@block_two).toHaveClass("is--hidden")
