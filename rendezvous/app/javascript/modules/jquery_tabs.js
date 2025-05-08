import $ from 'jquery'
import 'jquery-ui/dist/jquery-ui.min';

document.addEventListener('turbolinks:load', function(){
  $('#tabbed').tabs();
})