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
      redirect_to root_path
    end
  end

  def destroy
    if signed_in?
      @order = Order.find(params[:id])
      @order.destroy
      redirect_to user_path(current_user)
    else
      redirect_to root_path
    end
  end

  def edit
    if signed_in?
      @title = "Edit order"
      @order = Order.find(params[:id])
      if (@order.user != current_user)
        flash[:error] = "Access denied"
        redirect_to current_user
      end

    end
  end

  def update
    if signed_in?
      @order = Order.find(params[:id])
      if @order.update_attributes(params[:order])
        flash[:success] = "Order saved successfuly"
        redirect_to user_path(current_user)
      else
        flash[:error] = "Error in order saving"
        @title = "Edit order"
        render 'edit'
      end

    else
      redirect_to root_path
    end
  end

end
