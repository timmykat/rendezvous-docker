// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
Dropzone.options.dropzoneUpload = {
  paramName: "picture[image]",
  url: '/pictures/upload.html',
  init: function() {
    this.on('success', function(file, htmlResponse) {
      // update the picture table
      $('table.pictures').prepend(htmlResponse);
      this.removeFile(file);
    });
  }
}

$(function() {
  $('table.pictures').on('click', 'button.delete', function(e) {
    e.preventDefault();
    var $button = $(e.target);
    if ($button.hasClass('delete')) {
      var id = $button.attr('id').replace('delete_','');
      $.get('/ajax/picture/delete/' + id, function() {
        $button.parent().parent().remove();
      });
    }
  });
  
  $('#gallery').magnificPopup({
    delegate: 'a', // child items selector, by clicking on it popup will open
    type: 'image',
    gallery: { 
      enabled: true,
      navigateByImgClick: true, 
      preload: [0,1]
    }
  });
});