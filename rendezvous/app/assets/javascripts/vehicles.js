(function($) {
  jQuery(document).ready(function() {
    // Toggle access to vehicle other fields
    
    var disableAndNullifyTextField = function($field) {
      $field.val('');
      itemAbility($field, 'disable');
    }
    var setSelectToNull = function($select) {
      $select.val(null);
    }
    var itemAbility = function($item, action) {
      if (action == 'enable') {
        $item.prop('disabled', false);
      } else if (action == 'disable') {
        $item.prop('disabled', true);
      }
    }
    
    var handleFieldInteractions = function($vehicle, $changed) {
      // Handle marque-model interrelationship:
      // If Citroen is not selected for marque - set model select to nil and disable, enable other model
      var $marque = $vehicle.find('.select-with-other.marques');
      var $model  = $vehicle.find('.select-with-other.models');
      
      var $marque_other = $marque.find('input[type=text]')
      var $model_other = $model.find('input[type=text]')    
      var $marque_select = $marque.find('select')
      var $model_select = $model.find('select')
      
      if ($marque_select.val() == 'Citroen') {
        disableAndNullifyTextField($marque_other);      
        disableAndNullifyTextField($model_other);
        itemAbility($model_select, 'enable');
        if (!$changed.is($model_select)) {
          setSelectToNull($model_select);
        }
      } else if ($marque_select.val() == 'Other') {
        setSelectToNull($model_select);
        itemAbility($model_select, 'disable');
        itemAbility($model_other, 'enable');
      } else {
        setSelectToNull($model_select);
        itemAbility($model_select, 'disable');
        itemAbility($model_other, 'enable');
      } 
    }
    var setValues = function($vehicle) {
      $vehicle.find('.select-with-other').each( function() {
        var selectValue = $(this).find('select').val();
        var otherValue = $(this).find('input[type=text]').val();
        var $hiddenInput = $(this).find('input[type=hidden]');
        if (selectValue.match(/other/i) || !selectValue) {
          $hiddenInput.val(otherValue);
        } else {
          $hiddenInput.val(selectValue);
        }
      });
    }
    
    // Function takes arguments of option set for select and event type
    var setSelectOrOtherFields = function(event, $changed, optionSet, optionDefault) {
    
      // On load, set select to hidden value
      if (event == 'load') {
        $('.select-with-other.' + optionSet).each(function() {
          var $hiddenInput = $(this).find('input[type=hidden]');
          var $selectInput = $(this).find('select');
          var $otherInput = $(this).find('input[type=text]');
          var value = $hiddenInput.val();
          
          // If there's no value, set the select to the default option and disable the other field
          // Otherwise if the value isn't a select value, set the text field
          // Else set the select
          if (!value) {
            $selectInput.val(optionDefault);
            disableAndNullifyTextField($otherInput);
          } else if (appData[optionSet].indexOf(value) < 0) {
            if (optionSet == 'marques') {
              $selectInput.val('Other');
            } else {
              setSelectToNull($selectInput);
              itemAbility($selectInput, 'disable');
            }
            $otherInput.val(value);
            $otherInput.prop('disabled', false);
          } else {
            $selectInput.val(value);
            disableAndNullifyTextField($otherInput);
          }
        });
      } else if (event == 'change') {
        var $selectWithOther = $changed.closest('.select-with-other');
        var $hiddenInput = $selectWithOther.find('input[type=hidden]');
        var $selectInput = $selectWithOther.find('select');
        var $otherInput = $selectWithOther.find('input[type=text]');
            
        if ($selectInput.val() && $selectInput.val().match(/other/i)) {
          itemAbility($otherInput, 'enable');
        }
        $vehicle = $selectWithOther.closest('.nested-fields');
        handleFieldInteractions($vehicle, $changed);
        setValues($vehicle);
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
}) (jQuery);
  
