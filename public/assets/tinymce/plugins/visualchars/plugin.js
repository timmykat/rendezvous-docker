tinymce.PluginManager.add("visualchars",function(e){function a(a){var t,s,i,r,c,d,l=e.getBody(),m=e.selection;if(n=!n,o.state=n,e.fire("VisualChars",{state:n}),a&&(d=m.getBookmark()),n)for(s=[],tinymce.walk(l,function(e){3==e.nodeType&&e.nodeValue&&-1!=e.nodeValue.indexOf(" ")&&s.push(e)},"childNodes"),i=0;i<s.length;i++){for(r=s[i].nodeValue,r=r.replace(/( )/g,'<span data-mce-bogus="1" class="mce-nbsp">$1</span>'),c=e.dom.create("div",null,r);t=c.lastChild;)e.dom.insertAfter(t,s[i]);e.dom.remove(s[i])}else for(s=e.dom.select("span.mce-nbsp",l),i=s.length-1;i>=0;i--)e.dom.remove(s[i],1);m.moveToBookmark(d)}function t(){var a=this;e.on("VisualChars",function(e){a.active(e.state)})}var n,o=this;e.addCommand("mceVisualChars",a),e.addButton("visualchars",{title:"Show invisible characters",cmd:"mceVisualChars",onPostRender:t}),e.addMenuItem("visualchars",{text:"Show invisible characters",cmd:"mceVisualChars",onPostRender:t,selectable:!0,context:"view",prependToContext:!0}),e.on("beforegetcontent",function(e){n&&"raw"!=e.format&&!e.draft&&(n=!0,a(!1))})});