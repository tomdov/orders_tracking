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
#

class Order < ActiveRecord::Base
  attr_accessible :description, :notes, :purchase_date, :site, :status, :status_date, :price

  validates :description,   :presence => true
  validates :site,          :presence => true
  validates :status,        :presence => true

  belongs_to :user
  default_scope :order => 'orders.created_at DESC'

end
