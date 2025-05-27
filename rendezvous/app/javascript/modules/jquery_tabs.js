import $ from 'jquery'
import 'jquery-ui/dist/jquery-ui.min';

document.addEventListener('turbo:load', function(){
  console.log('Running tab listener')
  $('#tabbed').tabs();
})