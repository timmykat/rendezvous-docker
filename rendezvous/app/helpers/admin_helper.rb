module AdminHelper
  def sunday_lunch_count
    Event::Registration.current.where(status: :complete).sum(:sunday_lunch_number)
  end

  def format_attendee_counts(reg)
    counts = []
    counts << "Adults: #{reg.number_of_adults}"   if reg.number_of_adults.to_i > 0
    counts << "Youths: #{reg.number_of_youths}"   if reg.number_of_youths.to_i > 0
    counts << "Children: #{reg.number_of_children}" if reg.number_of_children.to_i > 0

    # join with <br/> and mark as HTML safe so Rails doesn't escape the tags
    counts.join("<br/>").html_safe
  end

  def public_asset_mtime(logical_name)
    path = asset_path(logical_name)

    # remove leading /assets/
    filename = path.sub(%r{^/assets/}, "")

    full_path = Rails.root.join('public/assets', filename)

    File.exist?(full_path) ? File.mtime(full_path) : nil
  end

  def public_asset_info
    {
      application_js: public_asset_mtime('application.js'),
      admin_js: public_asset_mtime('admin.js'),
      application_css: public_asset_mtime('application.css')
    }
  end
end
