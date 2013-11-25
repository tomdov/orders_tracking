require 'factory_girl'

FactoryGirl.define do
  factory :user do
    name "Tom TT"
    email "tt.tt@tt.net"
    password "foobar"
    password_confirmation "foobar"
  end
end

FactoryGirl.define do
  sequence :email do |n|
  "person-#{n}@example.com"
  end
end

FactoryGirl.define do
  factory :micropost do
    content "Hi There"
    association :user
  end
end

FactoryGirl.define do
  factory :order do
    description "Order"
    site        "Buy4Me"
    status      "Ordered"
    association :user
  end
end