# app/inputs/simple_mde_input.rb
class SimpleMdeInput < SimpleForm::Inputs::TextInput
  def input(wrapper_options = nil)
    # Render the default textarea field with a specific ID for SimpleMDE
    input_html_options[:id] ||= "#{object_name}_#{attribute_name}_simple_mde"
    super(wrapper_options)
  end
end
