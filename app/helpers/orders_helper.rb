module OrdersHelper

  #return the amount of days from the first date to the second date
  def days_diff(first_date, second_date)
    (second_date - first_date).to_i
  end

  #return the absolute amount of days between 2 dates
  def days_diff_abs(first_date, second_date)
    abs_days = days_diff(first_date, second_date)
    abs_days = abs_days * (-1) if abs_days < 0
    return abs_days
  end

  #return "ago" if the first date is before the second date or the same date, and "ahead" if the first date is "bigger" the second
  def days_diff_ago_or_ahead(first_date, second_date)
    if days_diff(first_date, second_date) < 0
      "ahead"
    else
      "ago"
    end
  end

  def is_link?(link)
    #http:// or https://
    (link.at(0..6) == "http://") or (link.at(0..7) == "https://")
  end

  def manipulate_site_if_neccesery(site)
    max_site_length_without_truncating = 30
    str = site
    str = str.truncate(max_site_length_without_truncating) if is_link?(site)
    return str
  end

  def create_site_for_view(site)
    str = ""
    str += "\<a href=#{site}\>" if is_link?(site)
    str += manipulate_site_if_neccesery(site)
    str += "</a>" if is_link?(site)
    str.html_safe()
  end

end
