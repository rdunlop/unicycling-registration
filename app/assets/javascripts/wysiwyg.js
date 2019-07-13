//= require tinymce

/* Don't have access to jquery */
tinymce.init({
  selector: ".full_tinymce",
  plugins: "advlist autolink lists link image charmap print preview hr anchor pagebreak " +
    "searchreplace wordcount visualblocks visualchars code fullscreen " +
    "insertdatetime media nonbreaking save table contextmenu directionality " +
    "emoticons template paste textcolor colorpicker textpattern"
  ,
  toolbar: "insertfile undo redo | styleselect | bold italic | alignleft aligncenter alignright alignjustify | bullist numlist outdent indent | link image | print preview media | forecolor backcolor emoticons",
  image_advtab: true,
  relative_urls: false,
  convert_urls: false,
  // templates: [
  //   {title: 'Test template 1', content: 'Test 1'},
  //   {title: 'Test template 2', content: 'Test 2'}
  // ]
});
