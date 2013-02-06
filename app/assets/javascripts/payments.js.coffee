# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$(document).ready ->
	$("table.alternate tr:even").css "background-color", "#f9f9f9"
	$("table.alternate tr:odd").css "background-color", "#e1e1e1"
	$("table.alternate th").css "background-color", "#fff"
