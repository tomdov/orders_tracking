class UsersController < ApplicationController
  before_filter :authenticate, :except => [:show, :new, :create]
  before_filter :correct_user, :only => [:edit, :update]
  before_filter :admin_only,   :only => :destroy

  def index
    @users = User.paginate(:page => params[:page])
    @user  = current_user
    @title = "All users"

  end
  def show
    @user = User.find_by_id(params[:id])
    @title = @user.name
    @microposts = @user.microposts.paginate(:page => params[:page])
  end

  def new
    @user = User.new
    @title = "Sign Up"
  end

  def following
    @title = "Following"
    @user = User.find(params[:id])
    @users = @user.following.paginate(:page => params[:page])
    render 'show_follow'
  end

  def followers
    @title = "Followers"
    @user = User.find(params[:id])
    @users = @user.followers.paginate(:page => params[:page])
    render 'show_follow'
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      flash[:success] = "Welcome to the Sample app"
      sign_in(@user)
      redirect_to @user # possible user_path(@user) also
    else
      @title = "Sign Up"
      render 'new'
    end
  end

  def edit
    @title = "Edit user"
  end

  def update
    if @user.update_attributes(params[:user])
      flash[:success] = "User saved successfuly"
      redirect_to @user # possible user_path(@user) also
    else
      flash[:error] = "Error in user saving"
      @title = "Edit user"
      render 'edit'
    end

  end

  def destroy
      user = User.find(params[:id])
      if !currect_user?(user)
        user.destroy
        redirect_to users_path, :flash => { :success => "User successfully deleted" }
      else
        redirect_to users_path, :flash => { :error => "An admin can't delete itself" }
      end
  end

  private

    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_path) unless currect_user?(@user)
    end

    def admin_only
      redirect_to(root_path) unless current_user.admin?
    end

end
