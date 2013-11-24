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

class User < ActiveRecord::Base
  attr_accessor :password
  attr_accessible :email, :name,  :password, :password_confirmation, :admin
  email_regex = /\A[\w\+\-.]+@([\da-zA-Z\-.])*[\.]([a-zA-Z\..])+\z/i

  has_many :microposts, :dependent => :destroy
  has_many :relationships,  :dependent => :destroy,
                            :foreign_key => "follower_id"
  has_many :following, :through => :relationships,
                       :source => :followed

  has_many :rev_relationships, :dependent => :destroy,
                               :foreign_key => "followed_id",
                               :class_name => "Relationship"
  has_many :followers, :through => :rev_relationships,
                       :source => :follower

  validates :name,  :presence => true,
            :length => { :maximum => 50 }

  validates :email, :presence => true,
                    :format   => { :with => email_regex},
                    :uniqueness => { :case_sensitive => false }

  validates :password, :presence => true,
                      :confirmation => true,
                      :length => { :within => 4..40 }

  before_save :encrypt_password

  def has_password?(submitted_password)
    encrypted_password == encrypt(submitted_password)
  end

  def feed
    Micropost.from_users_followed_by(self)
  end

  def following?(followed)
    relationships.find_by_followed_id(followed)
  end

  def follow!(followed)
    relationships.create!(:followed_id => followed.id)
  end

  def unfollow!(followed)
    followed_user = relationships.find_by_followed_id(followed.id)
    followed_user.destroy
  end

  def User.authenticate(email, password)
    user = find_by_email(email)
    (user && user.has_password?(password)) ? user : nil
  end

  def User.authenticate_with_salt(id, cookie_salt)
    user = find_by_id(id)
    (user && user.salt == cookie_salt) ? user : nil
  end

  private

  def encrypt(string)
    secure_hash("#{salt}--#{string}")
  end

  def encrypt_password
      self.salt = make_salt if new_record?
      self.encrypted_password = encrypt(password) # self is not necessary on the "password" but it is necessary on the
                                                  # start line because elsewise it will create a local variable */
    end

    def make_salt
      secure_hash("#{Time.now.utc}")
    end

    def secure_hash(string)
      Digest::SHA2.hexdigest(string)
    end
end
