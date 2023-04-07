const braintreeClient = require('braintree-web/client');
const  hostedFields = require('braintree-web/hosted-fields');

let myHostedFields;

function buildBraintree(clientToken) {
  let form = document.querySelector('#event_registration_form');
  let submit = document.querySelector('input[type="submit"]');

  braintreeClient.create({ authorization: clientToken }, function(clientErr, clientInstance) {

    if (clientErr) {
      console.error(clientEerr);
      return;
    }

    let hostedFieldOptions = {
      client: clientInstance,

      id: 'event_registration_form',
      fields: {
        number: {
          selector: '#card-number'
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

    hostedFields.create(hostedFieldOptions, function(hostedFieldsErr, hostedFieldsInstance) {

      myHostedFields = hostedFieldsInstance;

      if (hostedFieldsErr) {
        console.error(hostedFieldsErr);
        return;
      }

      // Set up events
      hostedFieldsInstance.on('cardTypeChange', function(e) {
        if (e.wells.length === 1) {
          $('td#logo').addClass(e.wells[0].type);
        } else {
          $('td#logo').attr('class', '');
        }
      });

      hostedFieldsInstance.on('validityChange', function(e) {
        console.log(e);
        field = e.fields[e.emittedBy];
        let fieldClass;
        if (e.emittedBy === 'expirationDate') {
          fieldClass = ".expiration";
        } else if (e.emittedBy === 'cvv') {
          fieldClass = ".cvv";
        } else if (e.emittedBy == 'number') {
          fieldClass = '.credit-card';
        }

        console.log(field);
        console.log(fieldClass);
        console.log(field.isValid);

        if (field.isValid) {
          $('.submit-status ' + fieldClass + ' i').removeClass('hidden');
          $('.submit-status ' + fieldClass ).removeClass('text-danger').addClass('text-success');
        } else {
          $('.submit-status ' + fieldClass + ' i').addClass('hidden');
          $('.submit-status  ' + fieldClass ).removeClass('text-success').addClass('text-danger');
        }
      });

      submit.removeAttribute('disabled');

      form.addEventListener('submit', function(event) {
        console.log(myHostedFields);
        if (myHostedFields) {
          event.preventDefault();
          hostedFieldsInstance.tokenize(function(tokenizeErr, payload) {
            if (tokenizeErr) {
              console.error(tokenizeErr);
              return;
            }
            document.querySelector('input[name="payment_method_nonce"]').value = payload.nonce;
            form.submit();
          });
        }
      }, false);
    });
  });
};


$(function() {
  $.get('/payment_token.plain', function(clientToken) {
    console.log("Client token", clientToken);
    buildBraintree(clientToken);

    $('#event_registration_paid_method_credit_card').on('click', function() {
      buildBraintree(clientToken);
    });
    $('#event_registration_paid_method_check').on('click', function() {
      myHostedFields.teardown( function(teardownErr) {
        if (teardownErr) {
          console.error('Could not tear down HostedFields.');
        } else {
          console.log('HostedFields has been torn down.');
          myHostedFields = null;
        }
      });
    });
  });
});


//<![CDATA[
// let tlJsHost = ((window.location.protocol == "https:") ? "https://secure.comodo.com/" : "http://www.trustlogo.com/");
// document.write(unescape("%3Cscript src='" + tlJsHost + "trustlogo/javascript/trustlogo.js' type='text/javascript'%3E%3C/script%3E"));
//]]>
