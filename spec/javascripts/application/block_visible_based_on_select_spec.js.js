// Show/hide a block of content based on the specific value of a select box
//
// Example Usage:
// <select class="js--blockVisibleSource">
//  <option value="one">1</option>
//  <option value="two">2</option>
//  <option value="three">3</option>
// </select>
//
// <div class="js--blockVisibleTarget" data-show="['one', 'two']">
//   Some Content shown for nil/1/2
// </div>
//
// <div class="js--blockVisibleTarget" data-hide="['three']" >
//   Some content shown for nil/1/2
// </div>
//
// javascript:
//   new BlockVisibleBasedOnSelect($(".js--blockVisibleSource"), $(".js--blockVisibleTarget"), "is--hidden")
//
describe("BlockVisibleBasedOnSelect", function() {
  beforeEach(function() {
    this.selectInput = affix("select.js--blockVisibleSource");
    this.defaultOption = this.selectInput.affix("option");
    this.firstOption = this.selectInput.affix("option")
      .attr("value", "one");
    this.secondOption = this.selectInput.affix("option")
      .attr("value", "two");
  });

  describe("when a show block exists", function() {
    beforeEach(function() {
      this.block_one = affix("div.js--blockVisibleTarget")
        .attr("data-show", "['one']");
      this.block_two = affix("div.js--blockVisibleTarget")
        .attr("data-show", "['two']");

      new BlockVisibleBasedOnSelect(
        $(".js--blockVisibleSource"),
        $(".js--blockVisibleTarget"),
        "is--hidden");
    });

    it("shows all blocks by default", function() {
      expect(this.block_one).not.toHaveClass("is--hidden");
      expect(this.block_two).not.toHaveClass("is--hidden");
    });

    describe("when the select box has chosen 'one'", function() {
      beforeEach(function() {
        this.firstOption.prop("selected", true);
        this.selectInput.trigger("change");
      });

      it("shows block one", function() {
        expect(this.block_one).not.toHaveClass("is--hidden");
      });

      it("does not show block two", function() {
        expect(this.block_two).toHaveClass("is--hidden");
      });
    });

    describe("when a show block with 2 keys exists", function() {
      beforeEach(function() {
        this.block_one = affix("div.js--blockVisibleTarget")
          .attr("data-show", "['one', 'two']");
        this.block_two = affix("div.js--blockVisibleTarget")
          .attr("data-show", "['two', 'three']");

        new BlockVisibleBasedOnSelect(
          $(".js--blockVisibleSource"),
          $(".js--blockVisibleTarget"),
          "is--hidden");
      });

      it("shows all blocks by default", function() {
        expect(this.block_one).not.toHaveClass("is--hidden");
        expect(this.block_two).not.toHaveClass("is--hidden");
      });

      describe("when the select box has chosen 'one'", function() {
        beforeEach(function() {
          this.firstOption.prop("selected", true);
          this.selectInput.trigger("change");
        });

        it("shows block one", function() {
          expect(this.block_one).not.toHaveClass("is--hidden");
        });

        it("does not show block two", function() {
          expect(this.block_two).toHaveClass("is--hidden");
        });
      });
    });
  });
});
