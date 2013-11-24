module UsersHelper
  def userNameMaxLength
    50
  end

  def gravatar_for(user, options = { :size => 50 })
    gravatar_image_tag(user.email.downcase, :alt => user.name,
                                            :class => 'gravatar',
                                            :gravatar => options)
  end

  def update_user_attrs(user, name, email, pass, pass_conf)
    user.name = name
    user.email = email
    user.password = pass
    user.password_confirmation = pass_conf
    return user
  end
end
