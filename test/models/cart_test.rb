require 'test_helper'

class CartTest < ActiveSupport::TestCase

  test 'cart should create a new line item when adding a new product' do
    cart = Cart.create
    cart.add_product(products(:one).id, products(:one).price).save!
    assert_equal 1, cart.line_items.size
    # Add a new product
    cart.add_product(products(:ruby).id, products(:ruby).price).save!
    assert_equal 2, cart.line_items.size
    assert_equal (products(:one).price + products(:ruby).price), cart.total_price
  end

  test 'cart should update an existing line item when adding an existing product' do
    cart = Cart.create
    2.times do
      cart.add_product(products(:one).id, products(:one).price).save!
    end
    assert_equal 1, cart.line_items.size
    assert_equal (products(:one).price * 2), cart.total_price
    cart.save!
  end
end
