# == Schema Information
#
# Table name: orders
#
#  id            :integer          not null, primary key
#  description   :text
#  site          :text
#  purchase_date :date
#  status        :string(255)
#  status_date   :date
#  notes         :text
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  price         :string(255)
#  user_id       :integer
#

require 'spec_helper'

describe Order do
  before(:each) do
    @attr = {:description => "example desc", :site => "Ebay", :purchase_date => Date.current, :status => "Ordered",
             :status_date => Date.current, :notes => "Bla bla bla"}
  end

  it "should create a new instance given a valid attr" do
    Order.create!(@attr)
  end

  it "should require a description" do
    order_wo_description = Order.new(@attr.merge(:description => ""))
    order_wo_description.should_not be_valid
  end

  it "should require a site" do
    order_wo_site = Order.new(@attr.merge(:site => ""))
    order_wo_site.should_not be_valid
  end

  it "should require a status" do
    order_wo_status = Order.new(@attr.merge(:status => ""))
    order_wo_status.should_not be_valid
  end

  describe "interaction with user" do
    before(:each) do
      @user = FactoryGirl.create(:user)
      @order = @user.orders.create!(@attr)
    end

    it "should associate the order to the right user" do
      @user.orders.should include(@order)
      @order.user_id.should == @user.id
      @order.user.should == @user
    end
  end

end
