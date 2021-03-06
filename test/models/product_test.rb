require 'test_helper'

class ProductTest < ActiveSupport::TestCase
  fixtures :products

  def new_product(image_url)
    Product.new(title:       "My Book Title",
                description: "yyy",
                price:       1,
                image_url:   image_url)
  end

  test "product attributes must not be empty" do
    product = Product.new
    assert product.invalid?
    assert product.errors[:title].any?
    assert product.errors[:description].any?
    assert product.errors[:price].any?
    assert product.errors[:image_url].any?
  end

  test "product price must be positive" do
      product = Product.new(title:       "My Book Title",
                            description: "yyy",
                            image_url:   "zzz.jpg")
      product.price = -1
      assert product.invalid?
      assert_equal ["must be greater than or equal to 0.01"],
        product.errors[:price]

      product.price = 0
      assert product.invalid?
      assert_equal ["must be greater than or equal to 0.01"], 
        product.errors[:price]

      product.price = 1
      assert product.valid?
    end

  test "image url must be a gif png or jpg" do
    ok = %w{ fred.gif fred.jpg fred.png FRED.JPG FRED.Jpg
             http://a.b.c/x/y/z/fred.gif }
    bad = %w{ fred.doc fred.gif/more fred.gif.more }
    
    ok.each do |name|
      assert new_product(name).valid?, "#{name} should be valid"
    end

    bad.each do |name|
      assert new_product(name).invalid?, "#{name} shouldn't be valid"
    end
  end

  test "image url must be unique" do
    product = new_product(products(:ruby).image_url)
    assert product.invalid?
  end

  test "product is not valid without a unique title - i18n" do
    product = Product.new(title:       products(:ruby).title,
                          description: "yyy", 
                          price:       1, 
                          image_url:   "fred.gif")

    assert product.invalid?
    assert_equal [I18n.translate('errors.messages.taken')],
                 product.errors[:title]
  end

    test "product is not valid without a unique description - i18n" do
    product = Product.new(title:       "My Book",
                          description: products(:ruby).description, 
                          price:       1, 
                          image_url:   "fred.gif")

    assert product.invalid?
    assert_equal [I18n.translate('errors.messages.taken')],
                 product.errors[:description]
  end

  test "product title is at least 7 characters long" do
    product = Product.new(description: "yyy",
                price:       1,
                image_url:   "fred.gif")
    
    product.title = "Short"
    assert product.invalid?
    assert_equal ["is too short (minimum is 7 characters)"], 
      product.errors[:title]

    product.title = "Long Enough Title"
    assert product.valid?, "#{product.title} should be valid"
  end

end
