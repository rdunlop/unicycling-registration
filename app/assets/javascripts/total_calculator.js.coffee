# Calculate the total amount of money from multiple fields
# usage:
#  checkbox element:
#    class: 'js--costItem'
#    data: 'cents' - the cost (in cents) to add if this checkbox is checked
#
# totalDisplay:
#    class: (js--total) - class of the field in which to write the total

class @TotalCalculator

  constructor: (@checkboxElement, @totalDisplay) ->
    @bindSources()
    @calculateTotal()

  bindSources: ->
    @checkboxElement.on "change", =>
      @calculateTotal()

  calculateTotal: ->
    total_cents = 0
    @checkboxElement.each ->
      if ($(this).prop('checked'))
        total_cents += parseInt($(this).data("cents"))
    total = (total_cents / 100).toFixed(2)
    @totalDisplay.html(total)

$ ->
  new TotalCalculator($(".js--costItem"), $(".js--total"))
