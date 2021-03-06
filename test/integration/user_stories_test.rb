require 'test_helper'

class UserStoriesTest < ActionDispatch::IntegrationTest
  fixtures :products
  fixtures :carts
  LineItem.delete_all
  Order.delete_all
  ruby_book = products(:ruby)
  #a user goes to the store index page
  get "/"
  assert_response :success
  assert_template "index"
  #they select a product, adding it to their cart.
  xml_http_request :post, '/line_items', product_id: ruby_book.id
  assert_response :success 
  
  cart = Cart.find(session[:cart_id])
  assert_equal 1, cart.line_items.size
  assert_equal ruby_book, cart.line_items[0].product
  #they check out
  get "/orders/new"
  assert_response :success
  assert_template "new"
  #the order is correctly placed with entered information and a line item in the order that is taken from the cart
  post_via_redirect "/orders",
                    order: { name:     "Dave Thomas",
                             address:  "123 The Street",
                             email:    "dave@example.com",
                             pay_type: "Check" }
  assert_response :success
  assert_template "index"
  cart = Cart.find(session[:cart_id])
  assert_equal 0, cart.line_items.size
  
  orders = Order.all
  assert_equal 1, orders.size
  order = orders[0]
  
  assert_equal "Dave Thomas",      order.name
  assert_equal "123 The Street",   order.address
  assert_equal "dave@example.com", order.email
  assert_equal "Check",            order.pay_type
  
  assert_equal 1, order.line_items.size
  line_item = order.line_items[0]
  assert_equal ruby_book, line_item.product
  #a confirmation email is sent
  mail = ActionMailer::Base.deliveries.last
  assert_equal ["dave@example.com"], mail.to
  assert_equal 'Sam Ruby <depot@example.com>', mail[:from].value
  assert_equal "Pragmatic Store Order Confirmation", mail.subject


### Seeing resources when authorized and not when unauthorized ####

test "should fail on access of sensitive data" do
    # login user
    user = users(:one)
    get "/login" 
    assert_response :success
    post_via_redirect "/login", name: user.name, password: 'secret'
    assert_response :success
    assert_equal '/admin', path

    # look at a protected resource
    get "/carts/12345" 
    assert_response :success  
    assert_equal '/carts/12345', path

    # logout user
    delete "/logout" 
    assert_response :redirect
    assert_template "/"      

    #try to look at protected resource again, should be redirected to login page
    get "/carts/12345" 
    assert_response :redirect
    follow_redirect!  
    assert_equal '/login', path      
  end


end
