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

end
