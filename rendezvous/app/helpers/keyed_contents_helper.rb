module KeyedContentsHelper
  include MarkdownConcern

  def keyed_content_options
    KeyedContent.keys
  end

  def keyed_content(key)
    record = KeyedContent.find_by_key key
    if record.nil? || record.content.nil?
      content = needs_content(key)
    else 
      content = record.as_html(:content)
    end
    content.html_safe
  end
end
