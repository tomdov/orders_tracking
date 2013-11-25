require 'spec_helper'

describe PagesController do
  render_views


  before(:each) do
    @base_title = "Ruby on Rails Tutorial Sample App"
  end

  describe "GET 'home'" do
    describe "when signed in" do
      it "returns http success" do
        get 'home'
        response.should be_success
      end

      it "should have the right title" do
        get 'home'
        response.should have_selector("title",
        :content => "#{@base_title} | Home")
      end

      it "should have a non-blank body" do
        get 'home'
        response.body.should_not =~ /<body>\s*<\/body>/
      end
    end

    describe "when signed in" do
      before(:each) do
        @user = test_sign_in(FactoryGirl.create(:user))
        other_user = FactoryGirl.create(:user, :email => FactoryGirl.generate(:email))
      end

      describe "User orders" do

        before(:each) do
          @attr = {:description => "example desc", :site => "Ebay", :purchase_date => Date.current, :status => "Ordered",
                   :status_date => Date.current, :notes => "Bla bla bla"}
          @user.orders.create!(@attr)
        end

        it "should contain the order" do
          get 'home'
          response.should have_selector('span', :content => @attr[:description])
        end
      end
    end
  end

  describe "GET 'contact'" do
    it "returns http success" do
      get 'contact'
      response.should be_success
    end
   
    it "should have the right title" do
      get 'contact'
      response.should have_selector("title",
      :content => "#{@base_title} | Contact")
    end

  end

  describe "GET 'about'" do
    it "returns http success" do
      get 'about'
	response.should be_success
    end
  
    it "should have the right title" do
      get 'about'
      response.should have_selector("title",
      :content => "#{@base_title} | About")
    end

  end

  describe "GET 'help'" do
    it "returns http success" do
      get 'help'
      response.should be_success
    end

    it "should have the right title" do
      get 'help'
      response.should have_selector("title",
                                    :content => "#{@base_title} | Help")
    end
  end

end
