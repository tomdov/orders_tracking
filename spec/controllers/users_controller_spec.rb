require 'spec_helper'

describe UsersController do
  render_views

  describe "Get 'index'" do

    describe "for non-signed-in users" do
      it 'should deny access' do
        get :index
        response.should redirect_to(signin_path)
      end
    end

    describe "for signed-in users" do

      before(:each) do
        @user = test_sign_in(FactoryGirl.create(:user))
        FactoryGirl.create(:user, :email => "user@example.com")
        FactoryGirl.create(:user, :email => "user@example.net")

      30.times do
        FactoryGirl.create(:user,:email =>  FactoryGirl.generate(:email))

        end
      end
      it 'should be successful' do
        get :index
        response.should be_success
      end

      it 'should have the right title' do
        get :index
        response.should have_selector('title', :content => "All users")
      end

      it 'should have an element for each user' do
        get :index
        User.paginate(:page => 1).each do |user|
          response.should have_selector('li', :content => @user.name)
        end
      end

      it 'should paginate users' do
        get :index
        response.should have_selector('div.pagination')
        response.should have_selector('span.disabled', :content => 'Previous')
        response.should have_selector('a', :href => "/users?page=2",
                                           :content => "2")
        response.should have_selector('a', :href => "/users?page=2",
                                           :content => "Next")
      end

      it 'should have a delete link for admins' do
        @user.toggle!(:admin)
        other_user = User.all.second
        get :index
        response.should have_selector('a', :href => user_path(other_user),
                                      :content => "Delete")
      end

      it 'should not have a delete link for non-admins' do
        other_user = User.all.second
        get :index
        response.should_not have_selector('a', :href => user_path(other_user),
                                      :content => "Delete")
      end


    end

  end

  describe "Get 'show'" do

    before(:each) do
      @user = FactoryGirl.create(:user)
      @base_title = "Ruby on Rails Tutorial Sample App"
    end

    it "should be successful" do
      get :show,  :id => @user
      response.should be_success
    end

    it "should find the right user" do
      get :show, :id => @user
      assigns(:user).should == @user    # assigns :user the @user from the users_controller
    end

    it "should have the right title" do
      get :show, :id => @user
      response.should have_selector('title', :content => @user.name)
    end

    it "should have the user's name" do
      get :show, :id => @user
      response.should have_selector('h1', :content => @user.name)
    end

    it "should have a profile image" do
      get :show, :id => @user
      response.should have_selector('h1>img', :class => "gravatar")
    end

    it "should have the right url" do
      get :show, :id => @user
      response.should have_selector('td>a', :content => user_path(@user),
                                            :href => user_path(@user))
    end

    it "should paginate" do
      35.times { FactoryGirl.create(:order, :user => @user) }
      get :show, :id => @user
      response.should have_selector('div.pagination')
    end

    describe "when singed in as another user" do
      it " should be successful" do
        test_sign_in(FactoryGirl.create(:user, :email => FactoryGirl.generate(:email)))
      end
    end

    describe "User orders" do

      before(:each) do
        test_sign_in(@user)
        @attr = {:description => "example desc", :site => "Ebay", :purchase_date => Date.current, :status => "Ordered",
                 :status_date => Date.current, :notes => "Bla bla bla"}
        @order1 = @user.orders.create!(@attr)
      end

      it "should contain the order" do
      get :show, :id => @user
        response.should have_selector('span', :content => @attr[:description])
      end

      it "should show delete link" do
        get :show, :id => @user
        response.should have_selector('a', :href => order_path(@order1), :content => "Delete")
      end

      it "should show edit link" do
        get :show, :id => @user
        response.should have_selector('a', :href => edit_order_path(@order1), :content => "Edit")
      end

    end

  end
  describe "GET 'new'" do
    it "returns http success" do
      get :new
      response.should be_success
    end

    it "should have the right title" do
      get :new
      response.should have_selector("title",
                                    :content => "Sign Up")
    end
  end

  describe "POST 'new'" do

    describe "failure" do

      before(:each) do
        @attr = { :name => "", :email => "", :password => "", :password_confirmation => "" }
      end

      it "should have the right title" do
        post :create, :user => @attr
        response.should have_selector('title', :content => "Sign Up")
      end

      it "should render the 'new' page" do
        post :create, :user => @attr
        response.should render_template('new')
      end

      it "should not create a user" do
        lambda do
          post :create, :user => @attr
        end.should_not change(User, :count)

      end
    end

    describe 'success' do
      before(:each) do
        @attr = { :name => 'new user', :email => "user@example.com",
                  :password => "1234", :password_confirmation => "1234" }
      end

      it "should create a user" do
        lambda do
          post :create, :user => @attr
        end.should change(User, :count).by(1)
      end

      it 'should redirect to the user show page' do
        post :create, :user => @attr
        response.should redirect_to(user_path(assigns(:user)))
      end

      it 'should have a welcome message' do
        post :create, :user => @attr
        flash[:success].should =~ /welcome to the sample app/i
      end

      it 'should sign the user in' do
        post :create, :user => @attr
        controller.should be_signed_in
      end
    end
  end

  describe 'GET "Edit"' do

    before(:each) do
      @user = FactoryGirl.create(:user)
      test_sign_in(@user)
    end

    it 'should be successful' do
      get :edit, :id => @user
      response.should be_success
    end

    it 'should have the right title' do
      get :edit, :id => @user
      response.should have_selector('title', :content => "Edit user")
    end

    it 'should have a link to change the Gravatar' do
      get :edit, :id => @user
      response.should have_selector('a', :href => 'http://gravatar.com/emails',
                                          :content => 'change')
    end

  end

  describe 'PUT "Update"' do
    before(:each) do
      @user = FactoryGirl.create(:user)
      test_sign_in(@user)
      @new_password = "12345"
    end

    describe 'success' do

      before(:each) do
        @attr = {:name => 'new-user',
                 :email => 'new@example.com',
                 :password => '12345',
                 :password_confirmation => '12345'}
      end

      it 'should display success message' do
        put :update, :user => @attr, :id => @user
        flash[:success].should =~ /User saved successfuly/i
      end

      it 'should render the "show" template' do
        put :update, :user => @attr, :id => @user
        @user.reload
        response.should redirect_to(@user)
      end

      it 'should update the user' do
        put :update, :user => @attr, :id => @user
        user = assigns(:user)
        @user.reload
        user.name.should == @user.name
        user.email.should == @user.email
        @user.has_password?(user.password)
      end

    end

    describe 'failure' do

      before(:each) do
        @attr = {:name => '',
                 :email => '',
                 :password => '',
                 :password_confirmation => ''}
      end
      it 'should display error message' do
        put :update, :user => @attr, :id => @user
        flash[:error].should =~ /Error in user saving/i
      end

      it 'should render the \'edit\' page' do
        put :update, :user => @attr, :id => @user
        response.should render_template('edit')
      end

      it 'should have the right title' do
        put :update, :user => @attr, :id => @user
        response.should have_selector('title', content: "Edit user")
      end
    end
  end

  describe 'authentication of edit/update actions' do

    before(:each) do
      @user = FactoryGirl.create(:user)
    end

    describe 'for non-sign-in users' do

      it 'should not allow access to \'edit\'' do
        get :edit, :id => @user
        response.should redirect_to(signin_path)
        flash[:notice].should =~ /sign in/i
      end

      it 'should deny access to \'update\'' do
        put :update, :id => @user, :user => {}
        response.should redirect_to(signin_path)
      end

    end

    describe 'for signed-in users' do

      before(:each) do
        wrong_user = FactoryGirl.create(:user, :email => "wrongUser@example.com")
        test_sign_in(wrong_user)
      end

      it 'should require matching users for \'edit\'' do
        get :edit, :id => @user
        response.should redirect_to(root_path)
      end

      it 'should require matching users for \'update\'' do
        get :update, :id => @user, :user => {}
        response.should redirect_to(root_path)
      end
    end

  end

  describe 'DELETE "destroy"' do

    before(:each) do
      @user = FactoryGirl.create(:user)
    end

    describe 'as a non-signed-in user' do
      it 'should deny access' do
        delete :destroy, :id => @user
        response.should redirect_to(signin_path)
      end
    end

    describe 'as a non-admin user' do
      it 'should protect the action' do
        test_sign_in(@user)
        delete :destroy, :id => @user
        response.should redirect_to(root_path)
      end
    end

    describe 'as an admin user' do

      before(:each) do
        @admin = FactoryGirl.create(:user, :email => "admin@example.com", :admin => true)
        test_sign_in(@admin)
      end

      it 'should destroy the user' do
        lambda do
          delete :destroy, :id => @user
        end.should change(User, :count).by(-1)

      end

      it 'should redirect to the users page' do
        delete :destroy, :id => @user
        flash[:success].should =~ /User successfully deleted/i
        response.should redirect_to(users_path)
      end

      it 'should not allow an admin to destroy itself' do
        lambda do
          delete :destroy, :id => @admin
        end.should_not change(User, :count)
        #flash[:error].should =~ /An admin can't delete itself/i
      end

    end
  end


end
