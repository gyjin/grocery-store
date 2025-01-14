require 'customer'
require 'pry'
require 'csv'

class Order
  attr_reader :id
  attr_accessor :products, :customer, :fulfillment_status
  
  def initialize(id, products, customer, fulfillment_status = :pending)
    @id = id
    @products = products
    @customer = customer
    
    # checking validity of fulfillment status
    case fulfillment_status
    when :pending, :paid, :processing, :shipped, :complete
      @fulfillment_status = fulfillment_status
    else
      raise ArgumentError.new("You have entered an invalid fulfillment status.")
    end
  end
  
  # method to calculate total cost of an order
  def total
    total = @products.values.inject {|sum, value| sum + value}
    if total.class == NilClass
      return total = 0
    else
      total *= 1.075
      return total.round(2)
    end
  end
  
  # method to add a product to an order 
  def add_product(product_name, price)
    if @products.has_key?(product_name) == true
      raise ArgumentError.new("This product has already been added.")
    else
      @products[product_name] = price
    end
  end
  
  # method to remove a product from the collection
  def remove_product(product_name)
    if @products.has_key?(product_name) == false
      raise ArgumentError.new("This product cannot be found.")
    else
      @products.delete(product_name)
    end
  end
  
  # method to return a collection of Order instances
  def self.all
    return CSV.open('data/orders.csv').map do |curr_order|
      products = {}
      product_price_in_element = curr_order[1].split(";")
      
      product_price_in_element.each do |product_price|
        separated = product_price.split(":")
        products[separated[0]] = separated[1].to_f
      end
      
      Order.new(curr_order[0].to_i, products, Customer.find(curr_order[-2].to_i), curr_order[-1].to_sym)
    end
  end
  
  # method to return an Order searched by id number
  def self.find(id)
    self.all.each do |order|
      if id == order.id
        return order
      end
    end
    return nil 
  end
  
  # method to return a list of orders by a customer
  def self.find_by_customer(customer_id)
    all_orders = self.all
    customer_orders = []
    
    all_orders.each do |each_order|
      if each_order.customer.id == customer_id
        customer_orders << each_order
      end
    end
    
    if customer_orders.length == 0
      raise ArgumentError.new("This customer does not exist.")
    else
      return customer_orders
    end
  end
  
  # ** attempt at Order.save but pry was throwing a "cannot load customer file" error
  # method to save Order instances to a csv file
  # def self.save(file_name)
  #   CSV.open(file_name, "w") do |file|
  #     self.all.each do |each_order|
  #       file << [
  #         each_order.id,
  #         each_order.products,
  #         each_order.customer.id,
  #         each_order.fulfillment_status
  #       ]
  #     end
  #   end
  # end
end


