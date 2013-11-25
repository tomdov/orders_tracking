require 'spec_helper'

describe OrdersController do
  render_views

  describe "get 'new'" do

    it "should response to new, create and destroy" do
      get :new
      response.should be_success
    end

    it "should have the right title" do
      get :new
      response.should have_selector("title", :content => "New order")
    end

  end

  describe "post 'create'" do

    before(:each) do
      @attr = {:description   => "example desc",
               :site          => "Ebay",
               :purchase_date => Date.current,
               :status        => "Ordered",
               :status_date   => Date.current,
               :notes         => "Bla bla bla"}
      @user = FactoryGirl.create(:user)

    end

    it "should redirect to the user feed" do
      test_sign_in(@user)
      post :create, :order => @attr

      response.should redirect_to(@user)
    end

    describe "failure" do

      it "should not add order if user isn't logged on" do
        lambda do
          post :create, :order => @attr
        end.should_not change(Order, :count)
      end

      it "should not add order if site is missing" do

        test_sign_in(@user)

        lambda do
          post :create, :order => @attr.merge(:site => "")
        end.should_not change(Order, :count)
      end

      it "should not add order if description is missing" do

        test_sign_in(@user)

        lambda do
          post :create, :order => @attr.merge(:description => "")
        end.should_not change(Order, :count)

      end
    end

    describe "success" do


      it "should add order to the DB" do
        test_sign_in(@user)
        lambda do
          post :create, :order => @attr
        end.should change(Order, :count).by(1)
      end

    end

  end

  describe "delete 'destroy'" do
    before(:each) do
      @attr = {:description   => "example desc",
               :site          => "Ebay",
               :purchase_date => Date.current,
               :status        => "Ordered",
               :status_date   => Date.current,
               :notes         => "Bla bla bla"}
      @user = test_sign_in(FactoryGirl.create(:user))
      @order = @user.orders.create(@attr)
    end

    it "should delete the order" do
      lambda do
        delete :destroy, :id => @order
      end.should change(Order, :count).by(-1)
    end

  end

  describe "get 'edit'" do
    before(:each) do
      @attr = {:description   => "example desc",
               :site          => "Ebay",
               :purchase_date => Date.current,
               :status        => "Ordered",
               :status_date   => Date.current,
               :notes         => "Bla bla bla"}
      @user = test_sign_in(FactoryGirl.create(:user))
      @order = @user.orders.create(@attr)
    end

    it "should be successful" do
      get :edit, :id => @order
      response.should be_success
    end

    it "should have the right title" do
      get :edit, :id => @order.id
      response.should have_selector('title', :content => "Edit order")
    end
  end

  describe "put 'update'" do
    before(:each) do
      @attr = {:description   => "example desc",
               :site          => "Ebay",
               :purchase_date => Date.current,
               :status        => "Ordered",
               :status_date   => Date.current,
               :notes         => "Bla bla bla"}

      @user = test_sign_in(FactoryGirl.create(:user))
      @order = @user.orders.create(@attr)
      @new_attr = {:description   => "new desc",
                   :site          => "new_Ebay",
                   :purchase_date => Date.current + 2.days,
                   :status        => "Delivered",
                   :status_date   => Date.current + 2.days,
                   :notes         => "new"}
    end

    it "should save successfully" do
      put :update, :order => @new_attr, :id => @order
      flash[:success].should =~ /Order saved successfuly/i
    end
    it "should redirect to the user" do
      put :update, :order => @new_attr, :id => @order
      response.should redirect_to @user
    end

    it "should update the order" do
      put :update, :order => @new_attr, :id => @order

      order = assigns(:order)
      @order.reload
      order.description.should      == @order.description
      order.site.should             == @order.site
      order.purchase_date.should    == @order.purchase_date
      order.status.should           == @order.status
      order.status_date.should      == @order.status_date
      order.notes.should.should     == @order.notes
    end

  end





end
