import $ from 'jquery'
import 'jquery-ui/dist/jquery-ui.min';

document.addEventListener('turbo:load', function() {
  $('#tabbed').tabs();
})