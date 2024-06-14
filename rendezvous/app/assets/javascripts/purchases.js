(function($) {
  jQuery(document).ready(function() {
    const creditCardSurchage = 0.03  // 3% credit card surcharge

    // Set up sources and targets
    let $purchase = $('#purchase')
    let $cartSubTotal = $('#subtotal')
    let $grandTotal = $('#total')
    let $totalLabel = $('[for=commerce_purchase_total]')
    let $cashTotalPaid = $('#commerce_purchase_cash_check_paid')

    let $emailField = $('#commerce_purchase_email')
    let $firstName = $('#commerce_purchase_first_name')
    let $lastName = $('#commerce_purchase_last_name')
    let $zipField = $('#commerce_purchase_postal_code')

    // payment method
    let $creditCardMethod = $('input[value="credit card"]')
    let $cashMethod = $('input[value="cash_or_check"]')

    // Cart fields
    let $cartItems = $('#cart_items')
    let $genericAmount = $('#commerce_purchase_generic_amount')

    /* Set up event listeners */
    $genericAmount.on('blur', function() {
      getGrandTotal()
    })

    $cartItems.on('change', 'select', function() {
      updateItem($(this))
      updateCartTotal()
      getGrandTotal()  
    })

    $cartItems.on('click', '.remove_fields', function() {
      setTimeout(function() {
        updateCartTotal()
        getGrandTotal() 
      }, 500)
    })

    // Payment methods
    $creditCardMethod.on('click', function() {
      $cashTotalPaid.val(0.0)
      getGrandTotal()
    })

    $cashMethod.on('click', function() {
      setTimeout(getGrandTotal(), 500)
      $cashTotalPaid.val($grandTotal.val())
    })

    $emailField.on('blur', function () {
      let email = $emailField.val()
      let data = { "email": email }
      $.get('/ajax/find_user_by_email', data, function(user) {
        if (user) {
          $firstName.val(user.first_name)
          $lastName.val(user.last_name)
          $zipField.val(user.postal_code)
        }
      }, 'json')
    })

    // calc functions
    let updateItem = function($selector) {
      $item = $selector.parents('.cart_item')

      let merchItemId, number
      if ($selector.hasClass('item_field')) {
        merchItemId = $selector.val()
        $otherSelector = $item.find('.number_field')
        number = parseFloat($otherSelector.val())
      } else if ($selector.hasClass('number_field')) {
        number = $selector.val()
        $otherSelector = $item.find('.item_field')
        merchItemId = $otherSelector.val()
      }
      
      let price = itemPrices[merchItemId]

      let itemTotal = price * number
      let $itemTotalField = $item.find('.item_total_field')
      $itemTotalField.val(itemTotal.toFixed(2))
    }

    let updateCartTotal = function() {
      let $cartItems = $purchase.find('#cart_items .cart_item')
      let sum = 0.0
      $cartItems.each(function(i) {
        sum += parseFloat($(this).find('.item_total_field').val())
      })
      $cartSubTotal.val(sum.toFixed(2))
    }

    let getGrandTotal = function() {
      let cartTotal = 0.0
      if ($cartSubTotal && $cartSubTotal.val()) { 
        cartTotal = parseFloat($cartSubTotal.val())
      }

      let genericAmount = $genericAmount.val() ? parseFloat($genericAmount.val()) : 0.0
      $grandTotal.val((cartTotal + genericAmount).toFixed(2))

      if ($cashMethod.is(':checked')) {
        $totalLabel.text('Total')
        $cashTotalPaid.val($grandTotal.val())
      } else if ($creditCardMethod.is(':checked')) {
        let totalWithCardFee = ($grandTotal.val() * (1.0 + creditCardSurchage)).toFixed(2)
        $totalLabel.text('Total (includes ' + (creditCardSurchage * 100) + '% credit card surcharge)')
        $grandTotal.val(totalWithCardFee)
      }
    }

  })
}) (jQuery);
