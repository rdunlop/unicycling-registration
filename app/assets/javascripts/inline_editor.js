// Public: edit a value in place.
//
// Within a ".js--inlineEdit" element, the ".js--inlineEditDisplay" element is shown,
// until its ".js--inlineEditOpen" link is clicked: it is then replaced by the
// ".js--inlineEditForm" form (hidden with "is--hidden"), whose first input is focused.
// The ".js--inlineEditCancel" link (or Escape) restores the display and the original value.

const close_inline_editor = function(editor) {
  const input = editor.find(".js--inlineEditForm :input:visible").first();
  input.val(input.prop("defaultValue"));
  editor.find(".js--inlineEditForm").addClass("is--hidden");
  editor.find(".js--inlineEditDisplay").removeClass("is--hidden");
};

$(document).on("click", ".js--inlineEditOpen", function() {
  const editor = $(this).closest(".js--inlineEdit");
  editor.find(".js--inlineEditDisplay").addClass("is--hidden");
  editor.find(".js--inlineEditForm").removeClass("is--hidden");
  editor.find(".js--inlineEditForm :input:visible").first().trigger("focus").trigger("select");
  return false;
});

$(document).on("click", ".js--inlineEditCancel", function() {
  close_inline_editor($(this).closest(".js--inlineEdit"));
  return false;
});

$(document).on("keydown", ".js--inlineEditForm :input", function(event) {
  if (event.key === "Escape") {
    close_inline_editor($(this).closest(".js--inlineEdit"));
  }
});
