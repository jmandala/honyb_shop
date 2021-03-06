class Cdf::OrderBuilder

  SCENARIOS = [
      {:id => 1, :name => 'single order/single line/single quantity'},
      {:id => 2, :name => 'single order/single line/multiple quantity', :line_item_qty => 2},
      {:id => 3, :name => 'single order/multiple lines/single quantity', :line_item_count => 2},
      {:id => 4, :name => 'single order/multiple lines/multiple quantity', :line_item_count => 2, :line_item_qty => 2},
      {:id => 5, :name => 'single order/multiple lines/multiple quantity: Hawaii', :line_item_count => 2, :line_item_qty => 2, :state_abbr => :HI},
      {:id => 6, :name => 'single order/multiple lines/multiple quantity: Alaska', :line_item_count => 2, :line_item_qty => 2, :state_abbr => :AK},
      {:id => 7, :name => 'single order/multiple lines/multiple quantity: Puerto Rico', :line_item_count => 2, :line_item_qty => 2, :state_abbr => :PR},
      {:id => 8, :name => 'single order/multiple lines/multiple quantity: USVI', :line_item_count => 2, :line_item_qty => 2, :state_abbr => :VI},
      {:id => 9, :name => 'single order/multiple lines/multiple quantity: UM', :line_item_count => 2, :line_item_qty => 2, :state_abbr => :UM},
      {:id => 10, :name => 'single order/multiple lines/multiple quantity: AE', :line_item_count => 2, :line_item_qty => 2, :state_abbr => :AE},
      {:id => 11, :name => 'single order/multiple lines/multiple quantity: AA', :line_item_count => 2, :line_item_qty => 2, :state_abbr => :AA},
      {:id => 12, :name => 'single order/multiple lines/multiple quantity: AP', :line_item_count => 2, :line_item_qty => 2, :state_abbr => :AP},
      {:id => 13, :name => 'single order/single lines/single quantity: P.O. Box', :address1 => 'P.O. Box 123'},
      {:id => 14, :name => 'Invalid Shipping Method: INTL Priority for Domestic', :state_abbr => :ME, :shipping_method => 'INTL Priority'},
      {:id => 15, :name => 'not yet received EAN', :ean_type => :not_yet_received},
      {:id => 16, :name => 'out of print/osi ean', :ean_type => :out_of_print},
      {:id => 17, :name => 'out of stock ean, backorder cancel', :ean_type => :out_of_stock_backorder_cancel},
      {:id => 18, :name => 'invalid ean', :ean_type => :invalid_ean},
      {:id => 19, :name => 'valid ean, not stocked by Ingram', :ean_type => :valid_not_stocked},
      {:id => 20, :name => 'warehouse shopping override: default', :dc_code => :default},
      {:id => 21, :name => 'warehouse shopping override: Chambersburg, PA', :dc_code => 'C'},
      {:id => 22, :name => 'warehouse shopping override: Fort Wayne, IA', :dc_code => 'D'},
      {:id => 23, :name => 'split shipment: multi shipment', :line_item_count => 2, :line_item_qty => 2, :ean_type => :split_ship, :split_shipment_type => :multi_shipment},
      {:id => 24, :name => 'split shipment: release when full', :ean_type => :split_ship, :split_shipment_type => :release_when_full},
      {:id => 25, :name => 'split shipment: dual shipment', :ean_type => :split_ship, :split_shipment_type => :dual_shipment},
      {:id => 26, :name => 'short ship/zero ship 100% of order', :ean_type => :slash_to_zero_ship},
      {:id => 27, :name => 'short ship/slash a single line from a multiple line order', :ean_type => [:slash_by_1, :in_stock]},
      {:id => 28, :name => 'short ship/slash a qty from a multiple line order', :line_item_qty => 4, :ean_type => [:slash_by_1, :in_stock]},
      {:id => 29, :name => 'backorder cancel reported in asn', :ean_type => :out_of_stock_backorder_cancel},
      {:id => 30, :name => 'backorder shipped on product receipt', :ean_type => :out_of_stock_backorder_ship},
      {:id => 31, :name => 'shipping 1 item in multiple boxes from the same DC: in stock', :line_item_qty => 30, :ean_type => :in_stock},
      {:id => 32, :name => 'shipping 1 item in multiple boxes from the same DC', :line_item_qty => 30, :ean_type => :multiple_boxes},
  ]

  def self.create_for_scenarios(scenarios=[])
    raise ArgumentError, "No scenarios given" if scenarios.empty?

    orders = []
    scenarios.each do |id|
      s = find_scenario id
      puts "create for #{s[:name]} [#{s[:id]}]"
      orders << completed_test_order(s)
    end
    orders
  end

  def self.create_for_scenario(name)
    raise ArgumentError, "No scenarios given" if name.nil?
    scenario = find_scenario_by_name name
    completed_test_order scenario
  end

  def self.find_scenario(id)
    SCENARIOS.each do |scenario|
      return scenario if scenario[:id] == id.to_i
    end
    raise ArgumentError, "No scenario found with id: '#{id}'"
  end

  def self.find_scenario_by_name(name)
    SCENARIOS.each do |scenario|
      return scenario if scenario[:name] == name
    end
    raise ArgumentError, "No scenario found with name: '#{name}'"
  end

  # Creates a new completed order setting default values, or values from the options passed
  # @param opts [Hash] hash of valid options including
  # - state_abbr
  # - line_item_count
  # - line_item_qty
  # - backordered_line_item_count
  # - backordered_line_item_qty
  # - dc_code
  # - split_shipment_type
  # - name
  # - ean_type
  # - ean
  # - order_number
  # @return [Order] a new order created with the options provided
  def self.completed_test_order(opts={})
    bill_address = create_address opts
    ship_address = create_address opts

    opts[:line_item_count] ||= 1
    opts[:line_item_qty] ||= 1
    opts[:backordered_line_item_count] ||= 0
    opts[:backordered_line_item_qty] ||= 1
    opts[:dc_code] ||= :default
    opts[:split_shipment_type] ||= :default

    order = Order.create_test_order
    order.order_name = opts[:name]
    order.number = opts[:order_number] if opts[:order_number]

    init_dc_code order, opts[:dc_code]
    init_split_shipment_type order, opts[:split_shipment_type]

    order.bill_address = bill_address
    order.ship_address = ship_address

    order.shipping_method = select_shipping_method order, opts

    product_builder = Cdf::ProductBuilder.new

    opts[:line_item_count].times do
      if opts[:ean]
        if opts[:ean].respond_to?(:each)
          opts[:ean].each { |ean| order.add_variant Cdf::ProductBuilder.create!(:sku => ean, :name => 'Custom Product').master, opts[:line_item_qty] }
        else
          order.add_variant Cdf::ProductBuilder.create!(:sku => opts[:ean], :name => 'Custom Product').master, opts[:line_item_qty]
        end
      else

        if opts[:ean_type].respond_to?(:each)
          opts[:ean_type].each { |ean_type| order.add_variant product_builder.next_product!(ean_type).master, opts[:line_item_qty] }
        else
          order.add_variant product_builder.next_product!(opts[:ean_type]).master, opts[:line_item_qty]
        end
      end
    end

    order.payments.create(
        :amount => order.total,
        :source => credit_card,
        :payment_method => bogus_payment_method
    )

    # finalize the order
    order.complete!

    # Authorizes all payments
    order.process_payments!

    # Capture payments
    order.capture_payments!
  end

  private

  def self.bogus_payment_method
    Gateway::Bogus.create!(:name => 'Credit Card', :environment => ENV['RAILS_ENV'])
  end

  def self.credit_card
    TestCard.create!(:verification_value => 123, :month => 12, :year => 2013, :number => "4111111111111111")
  end

  def self.select_shipping_method(order, opts={})
    opts[:shipping_method] ||= 'Economy Mail'
    ShippingMethod.find_by_name!(opts[:shipping_method])
  end

  def self.create_address(opts={})
    opts[:state_abbr] ||= :ME
    my_addr = address
    [:address1, :address2, :city].each do |field|
      my_addr.send("#{field.to_s}=", opts[field]) if opts[field]
    end

    if opts[:state_abbr]
      my_addr.state = State.find_by_abbr!(opts[:state_abbr])
      my_addr.country = my_addr.state.country
    end

    my_addr.save!
    my_addr
  end

  def self.address
    us = Country.find_by_iso('US')
    state = us.states[rand(us.states.size - 1)]

    Address.new(
        :firstname => random_string(:prefix => 'First Name'),
        :lastname => random_string(:prefix => 'Last Name'),
        :address1 => random_string(:prefix => 'Address 1'),
        :address2 => random_string(:prefix => 'Address 2'),
        :city => random_string(:prefix => 'City'),
        :state => state,
        :country => us,
        :zipcode => random_string(:length => 5),
        :phone => random_string(:length => 10),
        :alternative_phone => random_string(:length => 10)
    )
  end

  def self.random_string(opts={})
    opts[:length] ||= 12
    random = SecureRandom.base64(opts[:length])
    
    if opts[:prefix]
      return "#{opts[:prefix]}-#{random}" 
    end
    
    random
  end

  def self.init_dc_code(order, dc_code)
    order.dc_code = DcCode.find_by_po_dc_code!(dc_code) unless dc_code == :default
  end

  def self.init_split_shipment_type(order, split_shipment_type)
    order.split_shipment_type = Order::SPLIT_SHIPMENT_TYPE[split_shipment_type] unless split_shipment_type == :default
  end
end
