!function(e){if("object"==typeof exports&&"undefined"!=typeof module)module.exports=e();else if("function"==typeof define&&define.amd)define([],e);else{var t;t="undefined"!=typeof window?window:"undefined"!=typeof global?global:"undefined"!=typeof self?self:this,(t.braintree||(t.braintree={})).hostedFields=e()}}(function(){var e;return function t(e,n,r){function i(s,a){if(!n[s]){if(!e[s]){var c="function"==typeof require&&require;if(!a&&c)return c(s,!0);if(o)return o(s,!0);var l=new Error("Cannot find module '"+s+"'");throw l.code="MODULE_NOT_FOUND",l}var u=n[s]={exports:{}};e[s][0].call(u.exports,function(t){var n=e[s][1][t];return i(n?n:t)},u,u.exports,t,e,n,r)}return n[s].exports}for(var o="function"==typeof require&&require,s=0;s<r.length;s++)i(r[s]);return i}({1:[function(e,t,n){"use strict";function r(e){var t,n,r;return e?(t=e.prefixPattern.source,n=e.exactPattern.source,r=JSON.parse(JSON.stringify(e)),r.prefixPattern=t,r.exactPattern=n,r):null}function i(e){var t,n,i,s=[],a=[];if(!("string"==typeof e||e instanceof String))return[];for(i=0;i<I.length;i++)t=I[i],n=o[t],0!==e.length?n.exactPattern.test(e)?a.push(r(n)):n.prefixPattern.test(e)&&s.push(r(n)):s.push(r(n));return a.length?a:s}var o={},s="visa",a="master-card",c="american-express",l="diners-club",u="discover",d="jcb",f="unionpay",p="maestro",E="CVV",_="CID",h="CVC",y="CVN",I=[s,a,c,l,u,d,f,p];o[s]={niceType:"Visa",type:s,prefixPattern:/^4$/,exactPattern:/^4\d*$/,gaps:[4,8,12],lengths:[16,18,19],code:{name:E,size:3}},o[a]={niceType:"MasterCard",type:a,prefixPattern:/^(5|5[1-5]|2|22|222|222[1-9]|2[3-6]|27[0-1]|2720)$/,exactPattern:/^(5[1-5]|222[1-9]|2[3-6]|27[0-1]|2720)\d*$/,gaps:[4,8,12],lengths:[16],code:{name:h,size:3}},o[c]={niceType:"American Express",type:c,prefixPattern:/^(3|34|37)$/,exactPattern:/^3[47]\d*$/,isAmex:!0,gaps:[4,10],lengths:[15],code:{name:_,size:4}},o[l]={niceType:"Diners Club",type:l,prefixPattern:/^(3|3[0689]|30[0-5])$/,exactPattern:/^3(0[0-5]|[689])\d*$/,gaps:[4,10],lengths:[14],code:{name:E,size:3}},o[u]={niceType:"Discover",type:u,prefixPattern:/^(6|60|601|6011|65|64|64[4-9])$/,exactPattern:/^(6011|65|64[4-9])\d*$/,gaps:[4,8,12],lengths:[16,19],code:{name:_,size:3}},o[d]={niceType:"JCB",type:d,prefixPattern:/^(2|21|213|2131|1|18|180|1800|3|35)$/,exactPattern:/^(2131|1800|35)\d*$/,gaps:[4,8,12],lengths:[16],code:{name:E,size:3}},o[f]={niceType:"UnionPay",type:f,prefixPattern:/^(6|62)$/,exactPattern:/^62\d*$/,gaps:[4,8,12],lengths:[16,17,18,19],code:{name:y,size:3}},o[p]={niceType:"Maestro",type:p,prefixPattern:/^(5|5[06-9]|6\d*)$/,exactPattern:/^5[06-9]\d*$/,gaps:[4,8,12],lengths:[12,13,14,15,16,17,18,19],code:{name:h,size:3}},i.getTypeInfo=function(e){return r(o[e])},i.types={VISA:s,MASTERCARD:a,AMERICAN_EXPRESS:c,DINERS_CLUB:l,DISCOVER:u,JCB:d,UNIONPAY:f,MAESTRO:p},t.exports=i},{}],2:[function(t,n,r){(function(t){"use strict";!function(i,o){"object"==typeof r&&"undefined"!=typeof n?n.exports=o("undefined"==typeof t?i:t):"function"==typeof e&&e.amd?e([],function(){return o(i)}):i.framebus=o(i)}(this,function(e){function t(e){return null==e?!1:null==e.Window?!1:e.constructor!==e.Window?!1:(m.push(e),!0)}function n(e){var t,n={};for(t in D)D.hasOwnProperty(t)&&(n[t]=D[t]);return n._origin=e||"*",n}function r(e){var t,n,r=s(this);return a(e)?!1:a(r)?!1:(n=Array.prototype.slice.call(arguments,1),t=c(e,n,r),t===!1?!1:(_(T.top||T.self,t,r),!0))}function i(e,t){var n=s(this);return I(e,t,n)?!1:(S[n]=S[n]||{},S[n][e]=S[n][e]||[],S[n][e].push(t),!0)}function o(e,t){var n,r,i=s(this);if(I(e,t,i))return!1;if(r=S[i]&&S[i][e],!r)return!1;for(n=0;n<r.length;n++)if(r[n]===t)return r.splice(n,1),!0;return!1}function s(e){return e&&e._origin||"*"}function a(e){return"string"!=typeof e}function c(e,t,n){var r=!1,i={event:e,origin:n},o=t[t.length-1];"function"==typeof o&&(i.reply=y(o,n),t=t.slice(0,-1)),i.args=t;try{r=g+JSON.stringify(i)}catch(s){throw new Error("Could not stringify event: "+s.message)}return r}function l(e){var t,n,r,i;if(e.data.slice(0,g.length)!==g)return!1;try{t=JSON.parse(e.data.slice(g.length))}catch(o){return!1}return null!=t.reply&&(n=e.origin,r=e.source,i=t.reply,t.reply=function(e){var t=c(i,[e],n);return t===!1?!1:void r.postMessage(t,n)},t.args.push(t.reply)),t}function u(t){T||(T=t||e,T.addEventListener?T.addEventListener("message",f,!1):T.attachEvent?T.attachEvent("onmessage",f):null===T.onmessage?T.onmessage=f:T=null)}function d(){return"xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx".replace(/[xy]/g,function(e){var t=16*Math.random()|0,n="x"===e?t:3&t|8;return n.toString(16)})}function f(e){var t;a(e.data)||(t=l(e),t&&(p("*",t.event,t.args,e),p(e.origin,t.event,t.args,e),h(e.data,t.origin,e.source)))}function p(e,t,n,r){var i;if(S[e]&&S[e][t])for(i=0;i<S[e][t].length;i++)S[e][t][i].apply(r,n)}function E(e){return e.top!==e?!1:null==e.opener?!1:e.opener===e?!1:e.opener.closed===!0?!1:!0}function _(e,t,n){var r;try{for(e.postMessage(t,n),E(e)&&_(e.opener.top,t,n),r=0;r<e.frames.length;r++)_(e.frames[r],t,n)}catch(i){}}function h(e,t,n){var r,i;for(r=m.length-1;r>=0;r--)i=m[r],i.closed===!0?m=m.slice(r,1):n!==i&&_(i.top,e,t)}function y(e,t){function n(i,o){e(i,o),D.target(t).unsubscribe(r,n)}var r=d();return D.target(t).subscribe(r,n),r}function I(e,t,n){return a(e)?!0:"function"!=typeof t?!0:a(n)?!0:!1}var T,D,m=[],S={},g="/*framebus*/";return u(),D={target:n,include:t,publish:r,pub:r,trigger:r,emit:r,subscribe:i,sub:i,on:i,unsubscribe:o,unsub:o,off:o}})}).call(this,"undefined"!=typeof global?global:"undefined"!=typeof self?self:"undefined"!=typeof window?window:{})},{}],3:[function(e,t,n){"use strict";var r=e("./lib/set-attributes"),i=e("./lib/default-attributes"),o=e("./lib/assign");t.exports=function(e){var t=document.createElement("iframe"),n=o({},i,e);return n.style&&"string"!=typeof n.style&&(o(t.style,n.style),delete n.style),r(t,n),t.getAttribute("id")||(t.id=t.name),t}},{"./lib/assign":4,"./lib/default-attributes":5,"./lib/set-attributes":6}],4:[function(e,t,n){"use strict";t.exports=function(e){var t=Array.prototype.slice.call(arguments,1);return t.forEach(function(t){"object"==typeof t&&Object.keys(t).forEach(function(n){e[n]=t[n]})}),e}},{}],5:[function(e,t,n){"use strict";t.exports={src:"about:blank",frameBorder:0,allowtransparency:!0,scrolling:"no"}},{}],6:[function(e,t,n){"use strict";t.exports=function(e,t){var n;for(var r in t)t.hasOwnProperty(r)&&(n=t[r],null==n?e.removeAttribute(r):e.setAttribute(r,n))}},{}],7:[function(e,t,n){"use strict";function r(e,t){var n;return a.hasOwnProperty(e)?i(e,t)||(n=new o({type:s.HOSTED_FIELDS_ATTRIBUTE_VALUE_NOT_ALLOWED.type,code:s.HOSTED_FIELDS_ATTRIBUTE_VALUE_NOT_ALLOWED.code,message:'Value "'+t+'" is not allowed for "'+e+'" attribute.'})):n=new o({type:s.HOSTED_FIELDS_ATTRIBUTE_NOT_SUPPORTED.type,code:s.HOSTED_FIELDS_ATTRIBUTE_NOT_SUPPORTED.code,message:'The "'+e+'" attribute is not supported in Hosted Fields.'}),n}function i(e,t){return"string"===a[e]?"string"==typeof t||"number"==typeof t:"boolean"===a[e]?"true"===String(t)||"false"===String(t):!1}var o=e("../../lib/braintree-error"),s=e("../shared/errors"),a=e("../shared/constants").whitelistedAttributes;t.exports=r},{"../../lib/braintree-error":18,"../shared/constants":12,"../shared/errors":13}],8:[function(e,t,n){"use strict";var r=e("../shared/constants"),i=e("../../lib/use-min");t.exports=function(e,t,n){return e+"/web/"+r.VERSION+"/html/hosted-fields-frame"+i(n)+".html#"+t}},{"../../lib/use-min":38,"../shared/constants":12}],9:[function(e,t,n){"use strict";function r(e){return function(t){var n,r=t.merchantPayload,i=r.emittedBy,o=e[i].containerElement;Object.keys(r.fields).forEach(function(t){r.fields[t].container=e[t].containerElement}),n=r.fields[i],s.toggle(o,d.externalClasses.FOCUSED,n.isFocused),s.toggle(o,d.externalClasses.VALID,n.isValid),s.toggle(o,d.externalClasses.INVALID,!n.isPotentiallyValid),this._state={cards:r.cards,fields:r.fields},this._emit(t.type,r)}}function i(e){var t,n,_,h=this,y={},S=0,A=E();if(!e.client)throw new l({type:N.INSTANTIATION_OPTION_REQUIRED.type,code:N.INSTANTIATION_OPTION_REQUIRED.code,message:"options.client is required when instantiating Hosted Fields."});if(_=e.client.getConfiguration(),n=_.analyticsMetadata.sdkVersion,n!==g)throw new l({type:N.INCOMPATIBLE_VERSIONS.type,code:N.INCOMPATIBLE_VERSIONS.code,message:"Client (version "+n+") and Hosted Fields (version "+g+") components must be from the same SDK version."});if(!e.fields)throw new l({type:N.INSTANTIATION_OPTION_REQUIRED.type,code:N.INSTANTIATION_OPTION_REQUIRED.code,message:"options.fields is required when instantiating Hosted Fields."});T.call(this),this._injectedNodes=[],this._destructor=new o,this._fields=y,this._state={fields:{},cards:L("")},this._bus=new c({channel:A,merchantUrl:location.href}),this._destructor.registerFunctionForTeardown(function(){h._bus.teardown()}),this._client=e.client,m.sendEvent(this._client,"custom.hosted-fields.initialized"),Object.keys(e.fields).forEach(function(t){var n,r,i;if(!d.whitelistedFields.hasOwnProperty(t))throw new l({type:f.HOSTED_FIELDS_INVALID_FIELD_KEY.type,code:f.HOSTED_FIELDS_INVALID_FIELD_KEY.code,message:'"'+t+'" is not a valid field.'});if(n=e.fields[t],r=document.querySelector(n.selector),!r)throw new l({type:f.HOSTED_FIELDS_INVALID_FIELD_SELECTOR.type,code:f.HOSTED_FIELDS_INVALID_FIELD_SELECTOR.code,message:f.HOSTED_FIELDS_INVALID_FIELD_SELECTOR.message,details:{fieldSelector:n.selector,fieldKey:t}});if(r.querySelector('iframe[name^="braintree-"]'))throw new l({type:f.HOSTED_FIELDS_FIELD_DUPLICATE_IFRAME.type,code:f.HOSTED_FIELDS_FIELD_DUPLICATE_IFRAME.code,message:f.HOSTED_FIELDS_FIELD_DUPLICATE_IFRAME.message,details:{fieldSelector:n.selector,fieldKey:t}});i=a({type:t,name:"braintree-hosted-field-"+t,style:d.defaultIFrameStyle}),this._injectedNodes=this._injectedNodes.concat(D(i,r)),this._setupLabelFocus(t,r),y[t]={frameElement:i,containerElement:r},S++,this._state.fields[t]={isEmpty:!0,isValid:!1,isPotentiallyValid:!0,isFocused:!1,container:r},setTimeout(function(){i.src=u(_.gatewayConfiguration.assetsUrl,A,_.isDebug)},0)}.bind(this)),t=setTimeout(function(){m.sendEvent(h._client,"custom.hosted-fields.load.timed-out")},p),this._bus.on(I.FRAME_READY,function(n){S--,0===S&&(clearTimeout(t),n(e),h._emit("ready"))}),this._bus.on(I.INPUT_EVENT,r(y).bind(this)),this._destructor.registerFunctionForTeardown(function(){var e,t,n;for(e=0;e<h._injectedNodes.length;e++)t=h._injectedNodes[e],n=t.parentNode,n.removeChild(t),s.remove(n,d.externalClasses.FOCUSED,d.externalClasses.INVALID,d.externalClasses.VALID)}),this._destructor.registerFunctionForTeardown(function(){var e=O(i.prototype).concat(O(T.prototype));b(h,e)})}var o=e("../../lib/destructor"),s=e("../../lib/classlist"),a=e("iframer"),c=e("../../lib/bus"),l=e("../../lib/braintree-error"),u=e("./compose-url"),d=e("../shared/constants"),f=e("../shared/errors"),p=e("../../lib/constants").INTEGRATION_TIMEOUT_MS,E=e("../../lib/uuid"),_=e("../shared/find-parent-tags"),h=e("../../lib/throw-if-no-callback"),y=e("../../lib/is-ios"),I=d.events,T=e("../../lib/event-emitter"),D=e("./inject-frame"),m=e("../../lib/analytics"),S=d.whitelistedFields,g="3.9.0",O=e("../../lib/methods"),b=e("../../lib/convert-methods-to-error"),A=e("../../lib/deferred"),N=e("../../lib/errors"),L=e("credit-card-type"),v=e("./attribute-validation-error");i.prototype=Object.create(T.prototype,{constructor:i}),i.prototype._setupLabelFocus=function(e,t){function n(){s.emit(I.TRIGGER_INPUT_FOCUS,e)}var r,i,o=y(),s=this._bus;if(!o&&null!=t.id){for(r=Array.prototype.slice.call(document.querySelectorAll('label[for="'+t.id+'"]')),r=r.concat(_(t,"label")),i=0;i<r.length;i++)r[i].addEventListener("click",n,!1);this._destructor.registerFunctionForTeardown(function(){for(i=0;i<r.length;i++)r[i].removeEventListener("click",n,!1)})}},i.prototype.teardown=function(e){var t=this._client;this._destructor.teardown(function(n){m.sendEvent(t,"custom.hosted-fields.teardown-completed"),"function"==typeof e&&(e=A(e))(n)})},i.prototype.tokenize=function(e,t){t||(t=e,e={}),h(t,"tokenize"),this._bus.emit(I.TOKENIZATION_REQUEST,e,function(e){t.apply(null,e)})},i.prototype.addClass=function(e,t,n){var r;S.hasOwnProperty(e)?this._fields.hasOwnProperty(e)?this._bus.emit(I.ADD_CLASS,e,t):r=new l({type:f.HOSTED_FIELDS_FIELD_NOT_PRESENT.type,code:f.HOSTED_FIELDS_FIELD_NOT_PRESENT.code,message:'Cannot add class to "'+e+'" field because it is not part of the current Hosted Fields options.'}):r=new l({type:f.HOSTED_FIELDS_FIELD_INVALID.type,code:f.HOSTED_FIELDS_FIELD_INVALID.code,message:'"'+e+'" is not a valid field. You must use a valid field option when adding a class.'}),"function"==typeof n&&(n=A(n))(r)},i.prototype.removeClass=function(e,t,n){var r;S.hasOwnProperty(e)?this._fields.hasOwnProperty(e)?this._bus.emit(I.REMOVE_CLASS,e,t):r=new l({type:f.HOSTED_FIELDS_FIELD_NOT_PRESENT.type,code:f.HOSTED_FIELDS_FIELD_NOT_PRESENT.code,message:'Cannot remove class from "'+e+'" field because it is not part of the current Hosted Fields options.'}):r=new l({type:f.HOSTED_FIELDS_FIELD_INVALID.type,code:f.HOSTED_FIELDS_FIELD_INVALID.code,message:'"'+e+'" is not a valid field. You must use a valid field option when removing a class.'}),"function"==typeof n&&(n=A(n))(r)},i.prototype.setAttribute=function(e,t){var n,r;S.hasOwnProperty(e.field)?this._fields.hasOwnProperty(e.field)?(n=v(e.attribute,e.value),n?r=n:this._bus.emit(I.SET_ATTRIBUTE,e.field,e.attribute,e.value)):r=new l({type:f.HOSTED_FIELDS_FIELD_NOT_PRESENT.type,code:f.HOSTED_FIELDS_FIELD_NOT_PRESENT.code,message:'Cannot set attribute for "'+e.field+'" field because it is not part of the current Hosted Fields options.'}):r=new l({type:f.HOSTED_FIELDS_FIELD_INVALID.type,code:f.HOSTED_FIELDS_FIELD_INVALID.code,message:'"'+e.field+'" is not a valid field. You must use a valid field option when setting an attribute.'}),"function"==typeof t&&(t=A(t))(r)},i.prototype.setPlaceholder=function(e,t,n){this.setAttribute({field:e,attribute:"placeholder",value:t},n)},i.prototype.clear=function(e,t){var n;S.hasOwnProperty(e)?this._fields.hasOwnProperty(e)?this._bus.emit(I.CLEAR_FIELD,e):n=new l({type:f.HOSTED_FIELDS_FIELD_NOT_PRESENT.type,code:f.HOSTED_FIELDS_FIELD_NOT_PRESENT.code,message:'Cannot clear "'+e+'" field because it is not part of the current Hosted Fields options.'}):n=new l({type:f.HOSTED_FIELDS_FIELD_INVALID.type,code:f.HOSTED_FIELDS_FIELD_INVALID.code,message:'"'+e+'" is not a valid field. You must use a valid field option when clearing a field.'}),"function"==typeof t&&(t=A(t))(n)},i.prototype.getState=function(){return this._state},t.exports=i},{"../../lib/analytics":16,"../../lib/braintree-error":18,"../../lib/bus":21,"../../lib/classlist":22,"../../lib/constants":23,"../../lib/convert-methods-to-error":24,"../../lib/deferred":26,"../../lib/destructor":27,"../../lib/errors":29,"../../lib/event-emitter":30,"../../lib/is-ios":31,"../../lib/methods":34,"../../lib/throw-if-no-callback":37,"../../lib/uuid":39,"../shared/constants":12,"../shared/errors":13,"../shared/find-parent-tags":14,"./attribute-validation-error":7,"./compose-url":8,"./inject-frame":10,"credit-card-type":1,iframer:3}],10:[function(e,t,n){"use strict";t.exports=function(e,t){var n=document.createElement("div"),r=document.createDocumentFragment();return n.style.clear="both",r.appendChild(e),r.appendChild(n),t.appendChild(r),[e,n]}},{}],11:[function(e,t,n){"use strict";function r(e,t){var n;s(t,"create");try{n=new i(e)}catch(r){return t=o(t),void t(r)}n.on("ready",function(){t(null,n)})}var i=e("./external/hosted-fields"),o=e("../lib/deferred"),s=e("../lib/throw-if-no-callback"),a="3.9.0";t.exports={create:r,VERSION:a}},{"../lib/deferred":26,"../lib/throw-if-no-callback":37,"./external/hosted-fields":9}],12:[function(e,t,n){"use strict";var r=e("../../lib/enumerate"),i="3.9.0",o={VERSION:i,maxExpirationYearAge:19,externalEvents:{FOCUS:"focus",BLUR:"blur",EMPTY:"empty",NOT_EMPTY:"notEmpty",VALIDITY_CHANGE:"validityChange",CARD_TYPE_CHANGE:"cardTypeChange"},defaultMaxLengths:{number:19,postalCode:8,expirationDate:7,expirationMonth:2,expirationYear:4,cvv:3},externalClasses:{FOCUSED:"braintree-hosted-fields-focused",INVALID:"braintree-hosted-fields-invalid",VALID:"braintree-hosted-fields-valid"},defaultIFrameStyle:{border:"none",width:"100%",height:"100%","float":"left"},whitelistedStyles:["-moz-osx-font-smoothing","-moz-tap-highlight-color","-moz-transition","-webkit-font-smoothing","-webkit-tap-highlight-color","-webkit-transition","color","font","font-family","font-size","font-size-adjust","font-stretch","font-style","font-variant","font-variant-alternates","font-variant-caps","font-variant-east-asian","font-variant-ligatures","font-variant-numeric","font-weight","letter-spacing","line-height","opacity","outline","text-shadow","transition"],whitelistedFields:{number:{name:"credit-card-number",label:"Credit Card Number"},cvv:{name:"cvv",label:"CVV"},expirationDate:{name:"expiration",label:"Expiration Date"},expirationMonth:{name:"expiration-month",label:"Expiration Month"},expirationYear:{name:"expiration-year",label:"Expiration Year"},postalCode:{name:"postal-code",label:"Postal Code"}},whitelistedAttributes:{"aria-invalid":"boolean","aria-required":"boolean",disabled:"boolean",placeholder:"string"}};o.events=r(["FRAME_READY","VALIDATE_STRICT","CONFIGURATION","TOKENIZATION_REQUEST","INPUT_EVENT","TRIGGER_INPUT_FOCUS","ADD_CLASS","REMOVE_CLASS","SET_ATTRIBUTE","CLEAR_FIELD"],"hosted-fields:"),t.exports=o},{"../../lib/enumerate":28}],13:[function(e,t,n){"use strict";var r=e("../../lib/braintree-error");t.exports={HOSTED_FIELDS_INVALID_FIELD_KEY:{type:r.types.MERCHANT,code:"HOSTED_FIELDS_INVALID_FIELD_KEY"},HOSTED_FIELDS_INVALID_FIELD_SELECTOR:{type:r.types.MERCHANT,code:"HOSTED_FIELDS_INVALID_FIELD_SELECTOR",message:"Selector does not reference a valid DOM node."},HOSTED_FIELDS_FIELD_DUPLICATE_IFRAME:{type:r.types.MERCHANT,code:"HOSTED_FIELDS_FIELD_DUPLICATE_IFRAME",message:"Element already contains a Braintree iframe."},HOSTED_FIELDS_FIELD_INVALID:{type:r.types.MERCHANT,code:"HOSTED_FIELDS_FIELD_INVALID"},HOSTED_FIELDS_FIELD_NOT_PRESENT:{type:r.types.MERCHANT,code:"HOSTED_FIELDS_FIELD_NOT_PRESENT"},HOSTED_FIELDS_TOKENIZATION_NETWORK_ERROR:{type:r.types.NETWORK,code:"HOSTED_FIELDS_TOKENIZATION_NETWORK_ERROR",message:"A tokenization network error occurred."},HOSTED_FIELDS_FAILED_TOKENIZATION:{type:r.types.CUSTOMER,code:"HOSTED_FIELDS_FAILED_TOKENIZATION",message:"The supplied card data failed tokenization."},HOSTED_FIELDS_FIELDS_EMPTY:{type:r.types.CUSTOMER,code:"HOSTED_FIELDS_FIELDS_EMPTY",message:"All fields are empty. Cannot tokenize empty card fields."},HOSTED_FIELDS_FIELDS_INVALID:{type:r.types.CUSTOMER,code:"HOSTED_FIELDS_FIELDS_INVALID",message:"Some payment input fields are invalid. Cannot tokenize invalid card fields."},HOSTED_FIELDS_ATTRIBUTE_NOT_SUPPORTED:{type:r.types.MERCHANT,code:"HOSTED_FIELDS_ATTRIBUTE_NOT_SUPPORTED"},HOSTED_FIELDS_ATTRIBUTE_VALUE_NOT_ALLOWED:{type:r.types.MERCHANT,code:"HOSTED_FIELDS_ATTRIBUTE_VALUE_NOT_ALLOWED"}}},{"../../lib/braintree-error":18}],14:[function(e,t,n){"use strict";function r(e,t){for(var n=e.parentNode,r=[];null!=n;)null!=n.tagName&&n.tagName.toLowerCase()===t&&r.push(n),n=n.parentNode;return r}t.exports=r},{}],15:[function(e,t,n){"use strict";function r(e,t){var n,r=t?o(t):{},a=i(e.authorization).attrs,c=o(e.analyticsMetadata);r.braintreeLibraryVersion=s.BRAINTREE_LIBRARY_VERSION;for(n in r._meta)r._meta.hasOwnProperty(n)&&(c[n]=r._meta[n]);return r._meta=c,a.tokenizationKey?r.tokenizationKey=a.tokenizationKey:r.authorizationFingerprint=a.authorizationFingerprint,r}var i=e("./create-authorization-data"),o=e("./json-clone"),s=e("./constants");t.exports=r},{"./constants":23,"./create-authorization-data":25,"./json-clone":33}],16:[function(e,t,n){"use strict";function r(e){return Math.floor(e/1e3)}function i(e,t,n){var i=e.getConfiguration(),a=e._request,c=r(Date.now()),l=i.gatewayConfiguration.analytics.url,u={analytics:[{kind:o.ANALYTICS_PREFIX+t,timestamp:c}]};a({url:l,method:"post",data:s(i,u),timeout:o.ANALYTICS_REQUEST_TIMEOUT_MS},n)}var o=e("./constants"),s=e("./add-metadata");t.exports={sendEvent:i}},{"./add-metadata":15,"./constants":23}],17:[function(e,t,n){"use strict";function r(e,t){var n=0===e.length;n?(e(),t(null)):e(t)}var i=e("./once");t.exports=function(e,t){function n(e){return e?void c(e):(a-=1,void(0===a&&c(null)))}var o,s=e.length,a=s,c=i(t);if(0===s)return void c(null);for(o=0;s>o;o++)r(e[o],n)}},{"./once":35}],18:[function(e,t,n){"use strict";function r(e){if(!r.types.hasOwnProperty(e.type))throw new Error(e.type+" is not a valid type.");if(!e.code)throw new Error("Error code required.");if(!e.message)throw new Error("Error message required.");this.name="BraintreeError",this.code=e.code,this.message=e.message,this.type=e.type,this.details=e.details}var i=e("./enumerate");r.prototype=Object.create(Error.prototype),r.prototype.constructor=r,r.types=i(["CUSTOMER","MERCHANT","NETWORK","INTERNAL","UNKNOWN"]),t.exports=r},{"./enumerate":28}],19:[function(e,t,n){"use strict";function r(e,t){var n,r,o=document.createElement("a");return o.href=t,r="https:"===o.protocol?o.host.replace(/:443$/,""):"http:"===o.protocol?o.host.replace(/:80$/,""):o.host,n=o.protocol+"//"+r,n===e?!0:(o.href=e,i(e))}var i=e("../is-whitelisted-domain");t.exports={checkOrigin:r}},{"../is-whitelisted-domain":32}],20:[function(e,t,n){"use strict";var r=e("../enumerate");t.exports=r(["CONFIGURATION_REQUEST"],"bus:")},{"../enumerate":28}],21:[function(e,t,n){"use strict";function r(e){if(e=e||{},this.channel=e.channel,!this.channel)throw new a({type:a.types.INTERNAL,code:"MISSING_CHANNEL_ID",message:"Channel ID must be specified."});this.merchantUrl=e.merchantUrl,this._isDestroyed=!1,this._isVerbose=!1,this._listeners=[],this._log("new bus on channel "+this.channel,[location.href])}var i=e("framebus"),o=e("./events"),s=e("./check-origin").checkOrigin,a=e("../braintree-error");r.prototype.on=function(e,t){var n,r,o=t,a=this;this._isDestroyed||(this.merchantUrl&&(o=function(){s(this.origin,a.merchantUrl)&&t.apply(this,arguments)}),n=this._namespaceEvent(e),r=Array.prototype.slice.call(arguments),r[0]=n,r[1]=o,this._log("on",r),i.on.apply(i,r),this._listeners.push({eventName:e,handler:o,originalHandler:t}))},r.prototype.emit=function(e){var t;this._isDestroyed||(t=Array.prototype.slice.call(arguments),t[0]=this._namespaceEvent(e),this._log("emit",t),i.emit.apply(i,t))},r.prototype._offDirect=function(e){var t=Array.prototype.slice.call(arguments);this._isDestroyed||(t[0]=this._namespaceEvent(e),this._log("off",t),i.off.apply(i,t))},r.prototype.off=function(e,t){var n,r,i=t;if(!this._isDestroyed){if(this.merchantUrl)for(n=0;n<this._listeners.length;n++)r=this._listeners[n],r.originalHandler===t&&(i=r.handler);this._offDirect(e,i)}},r.prototype._namespaceEvent=function(e){return["braintree",this.channel,e].join(":")},r.prototype.teardown=function(){var e,t;for(t=0;t<this._listeners.length;t++)e=this._listeners[t],this._offDirect(e.eventName,e.handler);this._listeners.length=0,this._isDestroyed=!0},r.prototype._log=function(e,t){this._isVerbose&&console.log(e,t)},r.events=o,t.exports=r},{"../braintree-error":18,"./check-origin":19,"./events":20,framebus:2}],22:[function(e,t,n){"use strict";function r(e){return e.className.trim().split(/\s+/)}function i(e){var t=Array.prototype.slice.call(arguments,1),n=r(e).filter(function(e){return-1===t.indexOf(e)}).concat(t).join(" ");e.className=n}function o(e){var t=Array.prototype.slice.call(arguments,1),n=r(e).filter(function(e){return-1===t.indexOf(e)}).join(" ");e.className=n}function s(e,t,n){n?i(e,t):o(e,t)}t.exports={add:i,remove:o,toggle:s}},{}],23:[function(e,t,n){"use strict";var r="3.9.0",i="web";t.exports={ANALYTICS_PREFIX:"web.",ANALYTICS_REQUEST_TIMEOUT_MS:2e3,INTEGRATION_TIMEOUT_MS:6e4,VERSION:r,INTEGRATION:"custom",SOURCE:"client",PLATFORM:i,BRAINTREE_LIBRARY_VERSION:"braintree/"+i+"/"+r}},{}],24:[function(e,t,n){"use strict";var r=e("./braintree-error"),i=e("./errors");t.exports=function(e,t){t.forEach(function(t){e[t]=function(){throw new r({type:i.METHOD_CALLED_AFTER_TEARDOWN.type,code:i.METHOD_CALLED_AFTER_TEARDOWN.code,message:t+" cannot be called after teardown."})}})}},{"./braintree-error":18,"./errors":29}],25:[function(e,t,n){"use strict";function r(e){return/^[a-zA-Z0-9]+_[a-zA-Z0-9]+_[a-zA-Z0-9_]+$/.test(e)}function i(e){var t=e.split("_"),n=t[0],r=t.slice(2).join("_");return{merchantId:r,environment:n}}function o(e){var t,n,o={attrs:{},configUrl:""};return r(e)?(n=i(e),o.attrs.tokenizationKey=e,o.configUrl=a[n.environment]+"/merchants/"+n.merchantId+"/client_api/v1/configuration"):(t=JSON.parse(s(e)),o.attrs.authorizationFingerprint=t.authorizationFingerprint,o.configUrl=t.configUrl),o}var s=e("../lib/polyfill").atob,a={production:"https://api.braintreegateway.com:443",sandbox:"https://api.sandbox.braintreegateway.com:443"};t.exports=o},{"../lib/polyfill":36}],26:[function(e,t,n){"use strict";t.exports=function(e){return function(){var t=arguments;setTimeout(function(){e.apply(null,t)},1)}}},{}],27:[function(e,t,n){"use strict";function r(){this._teardownRegistry=[],this._isTearingDown=!1}var i=e("./batch-execute-functions");r.prototype.registerFunctionForTeardown=function(e){"function"==typeof e&&this._teardownRegistry.push(e)},r.prototype.teardown=function(e){return this._isTearingDown?void e(new Error("Destructor is already tearing down")):(this._isTearingDown=!0,void i(this._teardownRegistry,function(t){this._teardownRegistry=[],this._isTearingDown=!1,"function"==typeof e&&e(t)}.bind(this)))},t.exports=r},{"./batch-execute-functions":17}],28:[function(e,t,n){"use strict";function r(e,t){return t=null==t?"":t,e.reduce(function(e,n){return e[n]=t+n,e},{})}t.exports=r},{}],29:[function(e,t,n){"use strict";var r=e("./braintree-error");t.exports={CALLBACK_REQUIRED:{type:r.types.MERCHANT,code:"CALLBACK_REQUIRED"},INSTANTIATION_OPTION_REQUIRED:{type:r.types.MERCHANT,code:"INSTANTIATION_OPTION_REQUIRED"},INVALID_OPTION:{type:r.types.MERCHANT,code:"INVALID_OPTION"},INCOMPATIBLE_VERSIONS:{type:r.types.MERCHANT,code:"INCOMPATIBLE_VERSIONS"},METHOD_CALLED_AFTER_TEARDOWN:{type:r.types.MERCHANT,code:"METHOD_CALLED_AFTER_TEARDOWN"},BRAINTREE_API_ACCESS_RESTRICTED:{type:r.types.MERCHANT,code:"BRAINTREE_API_ACCESS_RESTRICTED",message:"Your access is restricted and cannot use this part of the Braintree API."}}},{"./braintree-error":18}],30:[function(e,t,n){"use strict";function r(){this._events={}}r.prototype.on=function(e,t){this._events[e]?this._events[e].push(t):this._events[e]=[t]},r.prototype._emit=function(e){var t,n,r=this._events[e];if(r)for(n=Array.prototype.slice.call(arguments,1),t=0;t<r.length;t++)r[t].apply(null,n)},t.exports=r},{}],31:[function(e,t,n){"use strict";t.exports=function(e){return e=e||navigator.userAgent,/(iPad|iPhone|iPod)/i.test(e)}},{}],32:[function(e,t,n){"use strict";function r(e){return e.split(".").slice(-2).join(".")}function i(e){var t;return e=e.toLowerCase(),/^https:/.test(e)?(o=o||document.createElement("a"),o.href=e,t=r(o.hostname),s.hasOwnProperty(t)):!1}var o,s={"paypal.com":1,"braintreepayments.com":1,"braintreegateway.com":1,"braintree-api.com":1};t.exports=i},{}],33:[function(e,t,n){"use strict";t.exports=function(e){return JSON.parse(JSON.stringify(e))}},{}],34:[function(e,t,n){"use strict";t.exports=function(e){return Object.keys(e).filter(function(t){return"function"==typeof e[t]})}},{}],35:[function(e,t,n){"use strict";function r(e){var t=!1;return function(){t||(t=!0,e.apply(null,arguments))}}t.exports=r},{}],36:[function(e,t,n){(function(e){"use strict";function n(e){var t,n,r,i,o,s,a,c,l=new RegExp("^(?:[A-Za-z0-9+/]{4})*(?:[A-Za-z0-9+/]{2}==|[A-Za-z0-9+/]{3}=|[A-Za-z0-9+/]{4})([=]{1,2})?$"),u="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=",d="";if(!l.test(e))throw new Error("Non base64 encoded input passed to window.atob polyfill");c=0;do i=u.indexOf(e.charAt(c++)),o=u.indexOf(e.charAt(c++)),s=u.indexOf(e.charAt(c++)),a=u.indexOf(e.charAt(c++)),t=(63&i)<<2|o>>4&3,n=(15&o)<<4|s>>2&15,r=(3&s)<<6|63&a,d+=String.fromCharCode(t)+(n?String.fromCharCode(n):"")+(r?String.fromCharCode(r):"");while(c<e.length);return d}var r="function"==typeof e.atob?e.atob:n;t.exports={atob:r,_atob:n}}).call(this,"undefined"!=typeof global?global:"undefined"!=typeof self?self:"undefined"!=typeof window?window:{})},{}],37:[function(e,t,n){"use strict";var r=e("./braintree-error"),i=e("./errors");t.exports=function(e,t){if("function"!=typeof e)throw new r({type:i.CALLBACK_REQUIRED.type,code:i.CALLBACK_REQUIRED.code,message:t+" must include a callback function."})}},{"./braintree-error":18,"./errors":29}],38:[function(e,t,n){"use strict";function r(e){return e?"":".min"}t.exports=r},{}],39:[function(e,t,n){"use strict";function r(){return"xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx".replace(/[xy]/g,function(e){var t=16*Math.random()|0,n="x"===e?t:3&t|8;return n.toString(16)})}t.exports=r},{}]},{},[11])(11)});