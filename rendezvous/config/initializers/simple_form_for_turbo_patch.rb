module SimpleForm
  module ActionViewExtensions
    module FormHelper
      alias_method :original_simple_form_for, :simple_form_for

      def simple_form_for(record, options = nil, *args, &block)
        options ||= {}
        options[:html] ||= {}
        options[:html][:data] ||= {}
        options[:html][:data][:turbo] = false

        original_simple_form_for(record, options, *args, &block)
      end
    end
  end
end