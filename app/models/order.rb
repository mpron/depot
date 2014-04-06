class Order < ActiveRecord::Base

  has_many :line_items, dependent: :destroy

  #for ship date update emails
  #after_update :send_new_ship_email, :if => :ship_date_changed? && :no_ship_date
  #after_update :send_changed_ship_email, :if => :ship_date_changed? && :ship_date_was

  PAYMENT_TYPES = ["Check", "Credit Card", "Purchase Order"]
  validates :name, :address, :email, presence: true
  validates :pay_type, inclusion: PAYMENT_TYPES

  def add_line_items_from_cart(cart)
    cart.line_items.each do |item|
      item.cart_id = nil
      line_items << item
    end
  end

  #def no_ship_date
  #  self.ship_date_was.nil?
  #end

  #def send_new_ship_email
  #  Notifier.order_shipped(self).deliver
  #end

  #def send_changed_ship_email
  #  Notifier.changed_shipping(self).deliver
  #end

end
