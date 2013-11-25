class OrdersController < ApplicationController

  def new
    @title = "New order"
    @order = Order.new
  end

  def create
    #TODO: check that we're signed in
    if signed_in?
      user_orders = current_user.orders
      @order = user_orders.build(params[:order].merge(:status => "Ordered"))
      @order.status_date = @order.purchase_date
      if @order.save
        flash[:success] = "Order saved!"
        redirect_to user_path(current_user)
      else
        @feed_items = []
        @title = "New order"
        render 'new'
      end
    else
      render 'new'
    end
  end

  def destroy

  end
end
