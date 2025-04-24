import { debounce } from 'throttle-debounce';

const scrollToElement = (el) => {
    if (el) {
        const yOffset = -50; // Adjust this value to account for any fixed headers, etc.
        const y = el.getBoundingClientRect().top + window.scrollY + yOffset;
        window.scrollTo({ top: y, behavior: 'smooth' });
    }
}

// Initialize the sticky header on scroll
const initStickyHeader = () => {
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
const initScrollLinks = () => {
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
const initAutocomplete = () => {
    const donationPage = document.querySelector('body.c_donations');
    const newRegistrationPage = document.querySelector('body.c_event_registrations .new_registration');
  
    if (donationPage || newRegistrationPage) {
      const autoComplete = document.querySelector('[data-autocomplete]');
      const fieldName = autoComplete.getAttribute('data-autocomplete');
      const targetFields = autoComplete.querySelectorAll('[data-autocomplete-target]');
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
  
      const debounceAutocomplete = debounce(500, function(event) {
        const field = event.target;
        let name = field.getAttribute('name');
        if (name == null) return;
        const searchAttribute = extractAttribute(name);
        const searchValue = encodeURIComponent(field.value);
        let url = `${autocompleteUrl}?${searchAttribute}=${searchValue}`;
        if (newRegistrationPage) {
          url += '&reg_page=1';
        }
        fetch(url, { headers: getCsrfHeaders() })
          .then(response => response.json())
          .then(data => {
            if (data.status === 'not found') {
              clearFields(targetFields);
              return;
            }
            if (data.existing_registration) {
              const alert = document.querySelector('.alert');
              alert.classList.remove('alert-warning');
              alert.classList.add('alert-danger');
              alert.innerHTML = `This user already has a registration: <a href="${data.existing_registration}">EDIT</a>`;
              return;
            }
            targetFields.forEach(field => {
              let name = field.getAttribute('name');
              let dataAttribute = extractAttribute(name);
              field.value = data[dataAttribute];
            });
          });
      });
  
      autocompleteTrigger.addEventListener('keyup', debounceAutocomplete);
    }
  };

  // Helper function to check if a value is numeric
const isNumeric = (value) => {
    return typeof value === 'string' && value.trim() !== '' && !Number.isNaN(Number(value));
  };
  
// Main initialization function to be called on DOMContentLoaded
const initCustom = () => {
  initStickyHeader();
  initScrollLinks();
  initAutocomplete();
};
  
// Execute the `init` function when the DOM is ready
document.addEventListener('DOMContentLoaded', initCustom);