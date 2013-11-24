# == Schema Information
#
# Table name: users
#
#  id                 :integer          not null, primary key
#  name               :string(255)
#  email              :string(255)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  encrypted_password :string(255)
#  salt               :string(255)
#  admin              :boolean          default(FALSE)
#

require 'spec_helper'

describe User do

  before(:each) do
    @attr = {:name=>"ex_user", :email=>"t.t@t.net", :password => "1234", :password_confirmation => "1234"}
    @max_len_name = 50
    @min_password_len = 4
    @max_password_len = 40
  end

  it "should create a new instance given a valid attr" do
    User.create!(@attr)
  end

  it "should require a name" do
    no_name_user = User.new(@attr.merge(:name => ""))
    no_name_user.should_not be_valid
  end

  it "should require a email" do
    User.new(@attr.merge(:email => "")).should_not be_valid
  end

  it "should reject names that are too long" do
    long_name_user = User.new(@attr.merge( :name => ("a" * (@max_len_name + 1))))
    long_name_user.should_not be_valid
  end

  it " should accept valid email address" do
    addresses = %w[user@foo.com THIS_IS_FULL_CAPS@GMAIL.COM hey.now@g.net]
    addresses.each do |address|
      valid_email_user = User.new(:name => "exmp_user", :email => address, :password => "1234", :password_confirmation => "1234")
      valid_email_user.should be_valid
    end

  end

  it "should not accept invalid email addresses" do
    addresses = %w[us@er@foo.com THIS_IS_FULL_CAPS@GMAIL,COM hey.now@g.]
    addresses.each do |address|
      invalid_email_user = User.new(:name => "exmp_user", :email => address)
      invalid_email_user.should_not be_valid
    end
  end

  it "should reject duplicate email addresses" do
    User.create!(@attr)
    user_with_dup_email = User.new(@attr)
    user_with_dup_email.should_not be_valid
  end

  it " should reject emails identical up to case" do
    mail = "user@expl.com"
    User.create!(@attr.merge(:email => mail))
    user_with_same_email = User.new(@attr.merge(:email => mail.upcase))
    user_with_same_email.should_not be_valid
  end

  describe "passwords" do
    it "should have a password attribute" do
      User.new(@attr).should respond_to(:password)
    end

    it "should have a password confimation" do
      User.new(@attr).should respond_to(:password_confirmation)
    end
  end

  describe "password validations" do
    it "should require a password" do
      User.new(@attr.merge(:password => "", :password_confirmation => "")).
      should_not be_valid
    end

    it "should require a matching password confimation" do
      User.new(@attr.merge(:password_confirmation => "invalid")).
      should_not be_valid

    end

    it "should reject a short password" do
      short = "a" * (@min_password_len - 1)
      User.new(@attr.merge(:password => short, :password_confirmation => short)).should_not be_valid
    end

    it "should reject long length password" do
      long = "a" * (@max_password_len + 1)
      User.new(@attr.merge(:password => long, :password_confirmation => long)).should_not be_valid
    end
  end

  describe "password encryption" do

    before(:each) do
      @user = User.create!(@attr)
    end

    it "should have an encrypted password attribute" do
      @user.should respond_to(:encrypted_password)
    end

    it "should set the encrypted password" do
      @user.encrypted_password.should_not be_blank
    end

    it "should have a salt" do
      @user.should respond_to(:salt)
    end

    describe "has_password? method" do

      it "should exist" do
        @user.should respond_to(:has_password?)
      end

      it "should return true if passwords match" do
        @user.has_password?(@attr[:password]).should be_true
      end

      it "should return false for not match passwords" do
        @user.has_password?("Invalid").should be_false
      end
    end

    describe "authenticate method" do

      it "should respond to authenticate" do
        User.should respond_to(:authenticate)
      end

      it "should return nil on email/password mismatch" do
        User.authenticate(@attr[:email], "wrongpass").should be_nil
      end

      it "should return nil for an email without user" do
        User.authenticate("userThatDoesntExist", @attr[:password]).should be_nil
      end

      it "should return the user on email/password match" do
        User.authenticate(@attr[:email], @attr[:password]).should == @user
      end
    end
  end

  describe 'micropost associations' do

    before(:each) do
      @user = User.create(@attr)
      @diff_user = User.create(@attr.merge(:email => "diff@exmaple.com"))
      @mp1  = FactoryGirl.create(:micropost, :user => @user, :created_at => 1.day.ago)
      @mp2  = FactoryGirl.create(:micropost, :user => @user, :created_at => 1.hour.ago)
      @mp3  = FactoryGirl.create(:micropost, :user => @diff_user, :created_at => 1.hour.ago)
    end

    it 'should have a microposts attr' do
      @user.should respond_to(:microposts)
    end

    it 'should have the right microposts in the right order' do
      @user.microposts.should == [@mp2, @mp1]
    end

    it 'should destroy the associated microposts' do
      @user.destroy
      [@mp1, @mp2].each do |micropost|
        lambda do
          Micropost.find(micropost.id)
        end.should raise_error(ActiveRecord::RecordNotFound)
        ##Micropost.find_by_id(micropost.id).should be_nil
      end
    end

    describe "status feed" do
      it "should have a feed" do
        @user.should respond_to(:feed)
      end

      it "should include the user's microposts" do
        @user.feed.should include(@mp1)
        @user.feed.should include(@mp2)
      end

      it "shouldn't include a different user's microposts" do
        @user.feed.should_not include(@mp3)
      end
    end
  end

  describe "relationships" do
    before(:each) do
      @user = User.create!(@attr)
      @followed = FactoryGirl.create(:user)
    end

    it "should have a relationships method" do
      @user.should respond_to(:relationships)
    end

    it "should have a following method" do
      @user.should respond_to(:following)
    end

    it "should follow another user" do
      @user.follow!(@followed)
      @user.should be_following(@followed)
    end

    it "should include the followed user in the following array" do
      @user.follow!(@followed)
      @user.following.should include(@followed)
    end

    it "should have an unfollow! method" do
      @user.should respond_to(:unfollow!)
    end

    it "should unfollow a user" do
      @user.follow!(@followed)
      @user.unfollow!(@followed)
      @user.should_not be_following(@followed)
    end

    it "should have a rev_relationships method" do
      @user.should respond_to(:rev_relationships)
    end

    it "should have a followers method" do
      @user.should respond_to(:followers)
    end

    it "should include the follower in the followers array" do
      @user.follow!(@followed)
      @followed.followers.should include(@user)
    end
  end
end
