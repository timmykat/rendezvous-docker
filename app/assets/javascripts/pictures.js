// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
Dropzone.options.dropzoneUpload = {
  paramName: "picture[image]"
}

$(function() {
  $('.pictures button.delete').on('click', function(e) {
    e.preventDefault();
    var $button = $(this);
    var id = $(this).attr('id').replace('delete_','');
    $.get('/ajax/picture/delete/' + id, function() {
      $button.parent(),parent().remove();
    });
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