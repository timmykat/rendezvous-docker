async function buildSquarePayments(applicationId, locationId) {
  
  const payments = Square.payments(applicationId, locationId)
  const card = await payments.card()

  await card.attach('#card-container')

  const cardButton = document.getElementById('card-button');
  const paymentToken = document.getElementById('payment_token')
  const formComplete = document.getElementById('event_registration_form')

  cardButton.addEventListener('click', async (e) => {
    e.preventDefault

    const statusContainer = document.getElementById('payment-status-container')

    try {
      const result = await card.tokenize();
      if (result.status === 'OK') {
        console.log(`Payment token is ${result.token}`);
        statusContainer.innerHTML = "Payment successful";
        paymentToken.value = result.token
        formComplete.submit()
      } else {
        let errorMessage = `Tokenization failed with status: ${result.status}`;
        if (result.errors) {
          errorMessage += ` and errors: ${JSON.stringify(
            result.errors
          )}`;
        }
        statusContainer.innerHTML = `Payment failed:  ${result.status}`;
        throw new Error(errorMessage);
      }
    } catch (e) {
      console.error(e);
      statusContainer.innerHTML = `Payment failed: ${e}`;
    }
  })
}
