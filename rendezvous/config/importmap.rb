# Pin npm packages by running ./bin/importmap
pin "application", to: "main.js"
pin "@hotwired/turbo-rails"
pin "@hotwired/stimulus"
pin "qrcode/html5"
pin_all_from "app/javascript/controllers", under: "controllers"
