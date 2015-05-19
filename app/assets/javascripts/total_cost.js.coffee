# Total up the floats in each of the elements
# usage:
#  target element:
#    class: 'js--totalCost'
#    data: 'costsources' - the class of the source elements
#
# source element:
#    class: class matching the costsources class

class @TotalCostDisplayer

  constructor: (@target)->
    @bindSources()
    @recalculateTotal()

  sourceClass: ->
    @target.data("costsources")

  sourceElements: ->
    $(".#{@sourceClass()}")

  bindSources: ->
    @sourceElements().on 'change', =>
      @recalculateTotal()

  recalculateTotal: ->
    total = 0
    @sourceElements().each ->
      total += parseFloat($(this).val())
    @target.val(total)

$ ->
  $(".js--totalCost").each (_, element) ->
    new TotalCostDisplayer($(element))
