require 'faker'

namespace :db do
   desc "Fill database with sample data"
  task :populate => :environment do
    Rake::Task['db:reset'].invoke
    make_users
    make_orders
  end
end

def make_users
    100.times do |n|
      name = Faker::Name.name
      email = "example-#{n+1}@railstitorial.org"
      password = "password"
      user = User.create!(:name =>  name,
                   :email => email,
                   :password => password,
                   :password_confirmation => password)
      user.toggle!(:admin) if n == 0
    end
end

def make_orders
    User.all(:limit => 6).each do |user|
      50.times do
        user.orders.create!(:description   => Faker::Lorem.sentence(1),
                            :site          => Faker::Lorem.sentence(1),
                            :purchase_date => Date.current,
                            :status        => "Ordered",
                            :status_date   => Date.current,
                            :notes         => Faker::Lorem.sentence(3))
      end
    end
end
