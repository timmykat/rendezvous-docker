import $ from 'jquery';

document.addEventListener('turbo:load',  function(){
  // Toggle access to vehicle other fields

  const otherFrench = ['Panhard', 'Peugeot', 'Renault']

  const disableField = function($field) {
    $field.val(null);
    $field.prop('disabled', true)
    setFieldInactive($field)
  }

  const enableField = function($field) {
    $field.prop('disabled', false)
    setFieldActive($field)
  }

  const setFieldActive = function($field) {
    $field.attr('data-active', true);
  }

  const setFieldInactive = function($field) {
    $field.removeAttr('data-active');
  }

  const updateRealValues = function($vehicle) {
    let $formDataMarque = $vehicle.find('.real-values .user_vehicles_marque input')
    let $formDataModel = $vehicle.find('.real-values .user_vehicles_model input')
    $vehicle.find('[data-active]').each(function() {
      let value = $(this).val()
      if ($(this).hasClass('marque')) {
        $formDataMarque.val(value)
      } else if ($(this).hasClass('model')) {
        $formDataModel.val(value)
      }
    });
  }

  const setVehicleInputs = function(event, $vehicle) {
    let $formDataMarque = $vehicle.find('.real-values .user_vehicles_marque input')
    let $formDataModel = $vehicle.find('.real-values .user_vehicles_model input')
    let $marqueSelect = $vehicle.find('.selects [name=select_marque]')
    let $modelSelect = $vehicle.find('.selects [name=select_model]')
    let $marqueField = $vehicle.find('.fill-in .marque')
    let $modelField = $vehicle.find('.fill-in .model')

    if (event === 'load') {
      if (!$formDataMarque.val() || $formDataMarque.val() === "Citroen") {
        enableField($marqueSelect);
        $marqueSelect.val("Citroen")
        enableField($modelSelect)
        $modelSelect.val($formDataModel.val())
        disableField($marqueField);
        disableField($modelField)
      } else {
        if (!otherFrench.includes($formDataMarque.val())) {
          enableField($marqueField)
          $marqueField.val($formDataMarque)
        } else {
          $marqueSelect.val($formDataMarque)
        }
        disableField($modelSelect)
        enableField($modelField, $formDataModel)
      }
      return
    }

    if ($marqueSelect.val() === 'Citroen') {
      enableField($marqueSelect);
      enableField($modelSelect);
      disableField($marqueField);
      disableField($modelField)
    } else if ($marqueSelect.val() === "Non-French") {
      setFieldInactive($marqueSelect)
      disableField($modelSelect)
      enableField($marqueField)
      enableField($modelField)
    } else {
      enableField($marqueSelect)
      enableField($modelField)
      disableField($marqueField)
      disableField($modelSelect)
    }
    if (event === 'change') {
      $modelField.val("")
    }
  }

  // Set up everything when loaded
  $('#vehicles .nested-fields').each(function() {
    console.log('Setting vehicle inputs for load')
    setVehicleInputs('load', $(this))
  });

  // Set up event handlers
  $('#vehicles').on('change', 'select', function() {
    console.log($(this))
    const $vehicle = $(this).closest('.nested-fields')
    console.log('Setting vehicle inputs for load', $vehicle)
    setVehicleInputs('change', $vehicle);
    updateRealValues($vehicle)
  });

  $('#vehicles').on('blur', 'input[type=text]', function() {
    const $vehicle = $(this).closest('.nested-fields')
    console.log('Setting vehicle inputs for blur', $vehicle)
    setVehicleInputs('blur', $vehicle);
    updateRealValues($vehicle)
  });
});
