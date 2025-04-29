import { Application } from "@hotwired/stimulus"

const application = Application.start()
const context = require.context(".", true, /\.js$/)
context.keys().forEach(filename => {
  if (!/index\.js$/.test(filename)) {   
    const controllerName = filename
      .replace(/^.\//, '')
      .replace(/_controller\.js$/, '')
      .replace(/\//g, "--")

    application.register(controllerName, context(filename).default)
  }
})
