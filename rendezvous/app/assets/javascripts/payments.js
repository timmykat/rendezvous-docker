const braintreeClient = require('braintree-web/client')
const  hostedFields = require('braintree-web/hosted-fields')

let myHostedFields

function buildBraintree(clientToken, formId) {
  console.log('*** Running buildBraintree')
  let form = document.querySelector('#' + formId)
  console.log('Form: ', form)
  let submit = document.querySelector('input[type="submit"]')
  console.log('Submit button: ', submit)

  braintreeClient.create({ authorization: clientToken }, function(clientErr, clientInstance) {
    console.log('*** Running client create')

    if (clientErr) {
      console.error(clientEerr)
      return
    }

    let hostedFieldOptions = {
      client: clientInstance,

      id: formId,
      fields: {
        number: {
          selector: '#card-number',
          placeholder: '1111 1111 1111 1111'
        },
        cvv: {
          selector: '#cvv',
          placeholder: '3 or 4 digits'
        },
        expirationDate: {
          selector: '#expiration-date',
          placeholder: 'MM/YY'
        }
      },
      styles: {
        "input": {
          "color": '#555',
          "font-size": '14px'
        }
      }
    }

    console.log('Hosted field options', hostedFieldOptions)

    hostedFields.create(
      hostedFieldOptions, 
      function(hostedFieldsErr, hostedFieldsInstance) {
        console.log('*** Runnging hostedFields setup callback')
        myHostedFields = hostedFieldsInstance

        console.log('myHostedFields: ', myHostedFields)

        if (hostedFieldsErr) {
          console.error(hostedFieldsErr)
          return
        }

        // Set up events
        hostedFieldsInstance.on('cardTypeChange', function(e) {
          if (e.cards.length === 1) {
            $('td#logo').addClass(e.cards[0].type)
          } else {
            $('td#logo').attr('class', '')
          }
        })

        hostedFieldsInstance.on('validityChange', function(e) {
          field = e.fields[e.emittedBy]
          let fieldClass
          if (e.emittedBy === 'expirationDate') {
            fieldClass = ".expiration"
          } else if (e.emittedBy === 'cvv') {
            fieldClass = ".cvv"
          } else if (e.emittedBy == 'number') {
            fieldClass = '.credit-card'
          }

          if (field.isValid) {
            $('.submit-status ' + fieldClass + ' i').removeClass('hidden')
            $('.submit-status ' + fieldClass ).removeClass('text-danger').addClass('text-success')
          } else {
            $('.submit-status ' + fieldClass + ' i').addClass('hidden')
            $('.submit-status  ' + fieldClass ).removeClass('text-success').addClass('text-danger')
          }
        })

        submit.removeAttribute('disabled')

        console.log('Setting up submit event listener')
        form.addEventListener('submit', function(event) {
          console.log('*** Hosted fields submit event')
          console.log(myHostedFields ? 'There are hosted fields' : 'Hosted fields missing!')
          
          if (myHostedFields) {
            event.preventDefault()
            hostedFieldsInstance.tokenize(function(tokenizeErr, payload) {
              if (tokenizeErr) {
                console.error('There has been a tokenize error: ', tokenizeErr)
                return
              }
              console.log('Payload nonce: ', payload.nonce)
              document.querySelector('input[name="payment_method_nonce"]').value = payload.nonce
              form.submit()
            })
          }
        }, false)
      })
  })
}


(function($) {
  jQuery(document).ready(function() {
    console.log('Setting up Braintree')
    if (document.getElementById('payment-section')) {
      let formId = document.querySelector('form').id
      console.log('Form ID: ', formId)
      $.get('/event/payment_token.plain', function(clientToken) {
        console.log('Getting token and building Braintree: ', clientToken)
        buildBraintree(clientToken, formId)

        $('#event_registration_paid_method_credit_card').on('click', function() {
          console.log('Credit card chosen -- building Braintree')
          buildBraintree(clientToken, formId)
        })
        $('#event_registration_paid_method_check').on('click', function() {
          console.log('Check chosen - tearing down hosted fields')
          myHostedFields.teardown( function(teardownErr) {
            if (teardownErr) {
              console.error('Could not tear down HostedFields.')
            } else {
              myHostedFields = null
            }
          })
        })
      })
    }
  })
}) (jQuery)


//<![CDATA[
// let tlJsHost = ((window.location.protocol == "https:") ? "https://secure.comodo.com/" : "http://www.trustlogo.com/")
// document.write(unescape("%3Cscript src='" + tlJsHost + "trustlogo/javascript/trustlogo.js' type='text/javascript'%3E%3C/script%3E"))
//]]>
