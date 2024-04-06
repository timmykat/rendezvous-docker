require 'pry'
Pry.config.prompt = Rails.env.production? ? Pry::Prompt[:rails].merge(value: "%l> ") : Pry::Prompt[:rails].merge(value: "%m> ")

