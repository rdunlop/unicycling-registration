# Total up the floats in each of the elements
# usage:
#  target element:
#    data: 'cost-total-ancestor' - the class of the an ancestor, from which to search for the data-cost-elements
#
# source element:
#    data: cost-element (set this attribute to true)

class @TotalCostDisplayer

  constructor: (@target)->
    @recalculateTotal()

  sourceClass: ->
    @target.data("cost-total-ancestor")

  sourceElements: ->
    $(@ancestorElement()).find("[data-cost-element]")

  ancestorElement: ->
    @target.closest(@target.data("cost-total-ancestor"))

  recalculateTotal: ->
    total = 0
    @sourceElements().each ->
      total += parseFloat($(this).val())
    @target.val(total)

$ ->
  $(document).on 'change', '[data-cost-element]', (element) =>
    $('[data-cost-total-ancestor]').each ->
      new TotalCostDisplayer($(this))

  # initial load
  $('[data-cost-total-ancestor]').each ->
    new TotalCostDisplayer($(this))
