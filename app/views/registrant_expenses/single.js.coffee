childIndex = new Date().getTime()

el = $($.trim('<%= escape_javascript(render(:partial => "registrant_expense_item", :locals => { :registrant_expense_item => @registrant_expense_item})) %>'))

el.html el.html().replace(/replace_with_js/g, childIndex)
el.attr("id", el.attr("id").replace(/replace_with_js/g, childIndex))

el.appendTo("#expense_lines")
  .hide()
  .fadeIn()
