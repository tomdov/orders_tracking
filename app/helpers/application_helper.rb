module ApplicationHelper

  # Return a title on a per-page basis.
  def title
    base_title = "Order Tracking"
    if @title.nil?
      base_title
    else
      "#{base_title} | #{@title}"
    end
  end

  def logo
    image_tag("logo_orders.png", :alt => "Order Tracking", :class => "round")
  end
end
