require 'spec_helper'

describe MicropostsController do
  render_views

  describe "access control" do
    it "should deny access to 'create'" do
      post :create
      response.should redirect_to(signin_path)
    end

    it "should deny access to 'destroy'" do
      delete :destroy, :id => 1
      response.should redirect_to(signin_path)
    end
  end

  describe "post 'create'" do

    before(:each) do
      @user = test_sign_in(FactoryGirl.create(:user))
    end

    describe "failure" do

      before(:each) do
        @attr = { :content => "" }
      end

      it "should not create a micropost" do
        lambda do
          post :create, :micropost => @attr
        end.should_not change(Micropost, :count)
      end

      it "should re-render the home page" do
        post :create, :micropost => @attr
        response.should render_template('pages/home')

      end
    end

    describe "success" do

      before(:each) do
        @attr = { :content => "Lorem bla bla" }
      end

      it "should create a micropost" do
        lambda do
          post :create, :micropost => @attr
        end.should change(Micropost, :count).by(1)

      end

      it "should redirect to the user root" do
        post :create, :micropost => @attr
        response.should redirect_to(root_path)
      end

      it "should show flash message" do
        post :create, :micropost => @attr
        flash[:success].should =~ /Micropost saved/i
      end
    end
  end

  describe "delete 'destroy'" do

    describe "unauthorized user" do
      before(:each) do
        @wrong_user = test_sign_in(FactoryGirl.create(:user))
        @user = FactoryGirl.create(:user, :email =>  FactoryGirl.generate(:email))
        @mp1  = FactoryGirl.create(:micropost, :user => @user, :created_at => 1.day.ago)
      end

      it "should deny delete" do
        lambda do
          delete :destroy, :id => @mp1
        end.should_not change(Micropost, :count)
      end

      it "should deny access" do
        delete :destroy, :id => @mp1
        response.should redirect_to root_path
      end

    end

    describe "authorized user" do
      before(:each) do
        @user = (FactoryGirl.create(:user))
        @mp1  = FactoryGirl.create(:micropost, :user => @user, :created_at => 1.day.ago)
        test_sign_in(@user)
      end

      it "should delete the micropost" do
        lambda do
          delete :destroy, :id => @mp1
          response.should redirect_to root_path
        end.should change(Micropost, :count).by(-1)
      end
    end
  end

end