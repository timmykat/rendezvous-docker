// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
Dropzone.options.dropzoneUpload = {
  paramName: "picture[image]",
  url: '/pictures/upload.html',
  maxFilesize: 2,
  init: function() {
    this.on('success', function(file, htmlResponse) {
      // update the picture table
      $('table.pictures').prepend(htmlResponse);
      this.removeFile(file);
    });
  }
}

$(function() {
  // Picture actions
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
  $('table.pictures').on('blur', '.credit input', function(e) {
    var $row = $(e.target).closest('tr');
    var picId = $row.attr('class').split('-')[1]
    $.ajax({
      url: '/pictures/' + picId,
      method: 'put',
      data: { 'picture[credit]': $(e.target).val() },
      dataType: 'json',
      success: function() {
        $row.css({ 'backgroundColor': '#CFC' });
        $row.animate({ 'backgroundColor': 'none' }, 1000);
      }
    }); 
    return false;  
  });
  $('table.pictures').on('change', '.year select', function(e) {
    var $row = $(e.target).closest('tr');
    var picId = $row.attr('class').split('-')[1]
    $.ajax({
      url: '/pictures/' + picId,
      method: 'put',
      data: { 'picture[year]': $(e.target).val() },
      dataType: 'json',
      success: function() {
        $row.css({ 'backgroundColor': '#CFC' });
        $row.animate({ 'backgroundColor': 'none' }, 1000);
      }
    });
    return false;   
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