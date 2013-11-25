require 'spec_helper'

describe OrdersController do

  describe "get 'new'" do

    it "should response to new, create and destroy" do
      get :new
      response.should be_success
    end

    it "should have the right title" do
      get :new
      response.should have_selector('title', :content => "New order")
    end

  end

  describe "post 'create'" do

    before(:each) do
      @attr = {:description => "example desc", :site => "Ebay", :purchase_date => Date.current, :status => "Ordered",
               :status_date => Date.current, :notes => "Bla bla bla"}
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
      @attr = {:description => "example desc", :site => "Ebay", :purchase_date => Date.current, :status => "Ordered",
               :status_date => Date.current, :notes => "Bla bla bla"}
      @user = test_sign_in(FactoryGirl.create(:user))
      @order = @user.orders.create(@attr)
    end

    it "should delete the order" do
      lambda do
        delete :destroy, :id => @order
      end.should change(Order, :count).by(-1)
    end

  end

  describe "post 'edit'" do
    before(:each) do
      @attr = {:description => "example desc", :site => "Ebay", :purchase_date => Date.current, :status => "Ordered",
               :status_date => Date.current, :notes => "Bla bla bla"}
      @user = test_sign_in(FactoryGirl.create(:user))
      @order = @user.orders.create(@attr)
    end

    it "should have the right title" do
      get :edit, :id => @order
      response.should have_selector('title', :content => "Edit order")
    end
  end





end
