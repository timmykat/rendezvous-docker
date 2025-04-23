#!/bin/bash
sass \
  ./app/assets/stylesheets/entrypoints/application.scss:./app/assets/builds/application.css \
  ./app/assets/stylesheets/entrypoints/vendor.scss:./app/assets/builds/vendor.css \
  --no-source-map --load-path=node_modules
