import { Application } from "@hotwired/stimulus"

const application = Application.start()
const context = require.context(".", true, /\.js$/)
context.keys().forEach(filename => {
  console.log("Controller filename: ", filename)
  if (!/index\.js$/.test(filename)) {   
    const controllerName = filename
      .replace(/^.\//, '')
      .replace(/_controller\.js$/, '')
      .replace(/\//g, "--")

    console.log("Controller name:", controllerName)
    application.register(controllerName, context(filename).default)
  }
})
