import Rails from "@rails/ujs"
import Turbolinks from "turbolinks"
import * as ActiveStorage from "@rails/activestorage"

import { debounce } from 'throttle-debounce';
import $ from 'jquery'; 
import 'html5shiv/dist/html5shiv.min';
import 'popper.js';
import 'bootstrap/dist/js/bootstrap';
import 'jquery-ui/ui/widgets/sortable';
import 'jquery-ui/ui/widgets/tabs';
import '../modules/rails_sortable';
import Cookies from 'js-cookie'; 
import 'magnific-popup/dist/jquery.magnific-popup.min';
import 'lazyload/lazyload.min';
import Cocoon from '@nathanvda/cocoon/cocoon';
import { initCustom } from '../modules/custom'
import '../modules/main_pages'; 
import '../modules/user'; 
import '../modules/vehicles'; 

Rails.start()
Turbolinks.start()
ActiveStorage.start()

