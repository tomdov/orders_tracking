class PagesController < ApplicationController
  def home
    @title = "Home"
    if signed_in?
      @user = current_user
      @feed_items = @user.orders.paginate(:page => params[:page])
    else
      @feed_items = []
    end
  end

  def contact
	@title = "Contact"
  end

  def about
	@title = "About"
  end

  def help
  @title = "Help"
  end
end
