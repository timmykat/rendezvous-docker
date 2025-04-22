# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

Rails.application.config.assets.paths << Rails.root.join('node_modules')
Rails.application.config.assets.paths << Rails.root.join('vendor/assets')

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
Rails.application.config.assets.precompile += %w(application-sprockets)
Rails.application.config.assets.precompile += %w(labels purchases @nathanvda/cocoon/cocoon)
Rails.application.config.assets.precompile += %w(simplemde/dist/simplemde.min.js simplemde/dist/simplemde.min.css)
Rails.application.config.assets.precompile += %w(bootstrap-icons/bootstrap-icons.svg)
puts "*****"
puts Rails.application.config.assets.precompile.inspect
puts

