import { debounce } from 'throttle-debounce';

export const scrollToElement = (el) => {
    if (el) {
        const yOffset = -50; // Adjust this value to account for any fixed headers, etc.
        const y = el.getBoundingClientRect().top + window.scrollY + yOffset;
        window.scrollTo({ top: y, behavior: 'smooth' });
    }
}

// Initialize the sticky header on scroll
export const initStickyHeader = () => {
    window.addEventListener('scroll', e => {
      let header = document.querySelector('header');
      if (!header) return;
      let stickyPoint = 115;
      let position = window.scrollY;
  
      if (position > stickyPoint) {
        header.classList.add('small');
      } else {
        header.classList.remove('small');
      }
    });
  };

// Initialize scroll links (anchor links in header)
export const initScrollLinks = () => {
    let scrollLinks = document.querySelectorAll('header.top-header a[href*="#"]');
    scrollLinks?.forEach(link => {
      link.addEventListener('click', e => {
        e.preventDefault();
        let targetId = e.target.getAttribute('href').replace('/#', '');
        let targetElement = document.getElementById(targetId);
        scrollToElement(targetElement);
      });
    });
  };

// Autocomplete functionality for donation and registration pages
export const initAutocomplete = () => {
    const donationPage = document.querySelector('body.c_donations');
    const newRegistrationPage = document.querySelector('body.c_event_registrations .new_registration');
  
    if (donationPage || newRegistrationPage) {
      const autoComplete = document.querySelector('[data-autocomplete]');
      const fieldName = autoComplete.getAttribute('data-autocomplete');
      const targetFields = autoComplete.querySelectorAll('[data-autocomplete-target]');
      const firstAttendeeField = document.querySelector('input[name="event_registration[attendees_attributes][0][name]"')
      const autocompleteTrigger = autoComplete.querySelector(`input[name*=${fieldName}]`);
  
      const autocompleteUrl = '/ajax/user/autocomplete';
  
      const extractAttribute = (name) => {
        const match = name?.match(/\[([a-z_]+)\]$/);
        return match && match[1];
      };
  
      const getCsrfHeaders = function() {
        let token = document.querySelector('meta[name="csrf-token"]').getAttribute('content');
        return {
          "Content-Type": "application/json",
          "X-CSRF-Token": token
        };
      };
  
      const clearFields = function(targetFields) {
        targetFields.forEach(field => {
          let name = field.getAttribute('name');
          field.value = '';
        });
      };
  
      const debounceAutocomplete = debounce(1000, function(event) {
        console.log(event)
        const field = event.target;
        let name = field.getAttribute('name');
        console.log(name)
        if (name == null) return;
        const searchAttribute = extractAttribute(name)
        const searchValue = encodeURIComponent(field.value)
        let url = `${autocompleteUrl}?${searchAttribute}=${searchValue}`;
        console.log('Autocomplete url: ', url)
        if (newRegistrationPage) {
          url += '&reg_page=1';
        }
        fetch(url, { headers: getCsrfHeaders() })
          .then(response => response.json())
          .then(data => {
            console.log('Fetch data:', data)
            if (data.status === 'not found') {
              clearFields(targetFields);
              return;
            }
            if (data.existing_registration) {
              alert(`This user already has a registration! (${data.existing_registration})`)
              return;
            }
            targetFields.forEach(field => {
              let name = field.getAttribute('name');
              let dataAttribute = extractAttribute(name);
              field.value = data[dataAttribute];
            });
            firstAttendeeField.value = `${data.first_name} ${data.last_name}`
          });
      });
  
      autocompleteTrigger.addEventListener('keyup', debounceAutocomplete);
    }
};

// Helper function to check if a value is numeric
const isNumeric = (value) => {
  return typeof value === 'string' && value.trim() !== '' && !Number.isNaN(Number(value));
};

export const setButtonSpinner = () => {
  document.querySelectorAll('[data-button-spinner]').forEach(button => {
    button.addEventListener('click', e => {
      const clicked = e.currentTarget;

      // Avoid adding multiple spinners
      if (clicked.nextSibling?.classList?.contains('spinner-grow')) return;

      const spinner = document.createElement('div');
      spinner.classList.add('spinner-grow', 'text-primary');
      spinner.setAttribute('role', 'status');

      const newText = clicked.dataset.buttonSpinner;
      if (clicked.tagName === 'INPUT') {
        clicked.value = newText;
      } else {
        clicked.textContent = newText;
      }

      clicked.after(spinner);
    });
  });
}

  
// Main initialization function to be called on DOMContentLoaded
export const initCustom = () => {
  initStickyHeader()
  initScrollLinks()
  initAutocomplete()
  setButtonSpinner()
};
