module AdminHelper
  def sunday_lunch_count
    Event::Registration.current.where(status: :complete).sum(:sunday_lunch_number)
  end

  def format_attendee_counts(reg)
    counts = []

    Event::Registration::AGE_GROUPS.each do |age|
      value = reg.send("number_of_#{age.pluralize}").to_i

      if value > 0
        counts << "#{age.pluralize.titleize}: #{value}"
      end
    end

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

  def potential_delete?(cand)
    !cand[:valid] || cand[:deny_list] || cand[:disposable] || !cand[:valid_mx] || cand[:subaddressed]
  end
end
