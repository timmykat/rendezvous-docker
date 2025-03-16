module KeyedContentsHelper
  include MarkdownConcern

  def keyed_content_options
    [
      "main_welcome",
      "main_other_accommodations",
      "main_volunteers",
      "main_vendors",
      "main_history",
      "page_legal",
      "page_history"     
    ]
  end

  def keyed_content(key)
    record = KeyedContent.find_by_key key
    if record.nil?
      content = needs_content(key)
    else 
      content = record.as_html(:content)
    end
    content.html_safe
  end
end
