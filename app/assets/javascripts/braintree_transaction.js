$(function() {
  $.get('/client_token', function(clientToken) {  
    Braintree.create(clientToken, "custom", {
      id: 'payment-form',
      hostedFields: {
        number: {
          selector: '#card-number',
          placeholder: 'Credit card number'
        },
        cvv: {
          selector: '#cvv',
        },
        expirationDate: {
          selector: '#expiration-date'
        },
        styles: {
          input: {
            backgroundColor: '#fff',
            backgroundImage: 'none',
            border: '1px solid #ccc',
            borderRadius: '4px',
            boxShadow: '0 1px 1px rgba(0, 0, 0, 0.075) inset',
            color: '#555',
            display: 'block',
            fontSize: '14px',
            height: '34px',
            lineHeight: '1.42857',
            padding: '6px 12px',
            transition: 'border-color 0.15s ease-in-out 0s, box-shadow 0.15s ease-in-out 0s',
            width: '100%',
          }
        }
      }
    });
  });
});
