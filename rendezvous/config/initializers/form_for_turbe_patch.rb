module ActionView
  module Helpers
    module FormHelper
      alias_method :original_form_for, :form_for

      def form_for(record, options = {}, *args, &block)
        options[:html] ||= {}
        options[:html][:data] ||= {}
        options[:html][:data][:turbo] = false

        original_form_for(record, options, *args, &block)
      end
    end
  end
end