$(function() {
  // Toggle access to vehicle other fields
  
  var disableTextField = function($field) {
    $field.val('');
    $field.prop('disabled', true);
  }
  
  var handleFieldInteractions = function() {
    // Handle marque-model interrelationship:
    // If Citroen is not selected for marque - set model select to nil and disable, enable other model
    var $marque = $('.select-with-other.marques');
    var $model  = $('.select-with-other.models');
    
    if ($marque.find('select').val() == 'Citroen') {
      disableTextField($marque.find('input[type=text]'));      
      disableTextField($model.find('input[type=text]'));
      $model.find('select').prop('disabled', false);
    } else {
      $model.find('select').prop('disabled', true);
      $model.find('input[type=text]').prop('disabled', false);
    }
  }
  var setValues = function() {
    $('.select-with-other').each( function() {
      var selectValue = $(this).find('select').val();
      var otherValue = $(this).find('input[type=text]').val();
      var $hidden = $(this).find('input[type=hidden]');
      if (selectValue.match(/other/i) || !selectValue) {
        $hidden.val(otherValue);
      } else {
        $hidden.val(selectValue);
      }
    });
  }
  
  // Function takes arguments of option set for select and event type
  var setSelectOrOtherFields = function(event, $changed, optionSet, optionDefault) {
    // On load, set select to hidden value
    if (event == 'load') {
      $('.select-with-other.' + optionSet).each(function() {
        var $hidden = $(this).find('input[type=hidden]');
        var $select = $(this).find('select');
        var $other = $(this).find('input[type=text]');
        var value = $hidden.val();
        
        // If there's no value, set the select to the default option and disable the other field
        // Otherwise if the value isn't a select value, set the text field
        // Else set the select
        if (!value) {
          $select.val(optionDefault);
          disableTextField($other);
        } else if (appData[optionSet].indexOf(value) < 0) {
          $select.val('Other');
          $other.val(value);
          $other.prop('disabled', false);
        } else {
          $select.val(value);
          disableTextField($other);
        }
      });
    } else if (event == 'change') {
      var $selectWithOther = $changed.closest('.select-with-other');
      var $hidden = $selectWithOther.find('input[type=hidden]');
      var $select = $selectWithOther.find('select');
      var $other = $selectWithOther.find('input[type=text]');
          
      if ($select.val() && $select.val().match(/other/i)) {
        $other.prop('disabled', false);
      }
      handleFieldInteractions();
      setValues();
    }    
  }
  
  // Run the function when loaded
  setSelectOrOtherFields('load', null, 'marques', 'Citroen');
  setSelectOrOtherFields('load', null, 'models', null);
  
  // Set up event handlers
  $('#vehicles').on('change', 'select', function() {
    setSelectOrOtherFields('change', $(this));  
  });
  $('#vehicles').on('blur', 'input[type=text]', function() {
    setSelectOrOtherFields('change', $(this));  
  });
});
  
