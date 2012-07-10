class Admin::Fulfillment::SystemCheckController < Admin::BaseController
  respond_to :html, :xml, :json

  def index
  end

  def order_check
    @scenarios = Cdf::OrderBuilder::SCENARIOS
  end

  
  # POST /admin/orders
  # Creates a new set of orders for Fulfillment testing
  def generate_test_orders
    if params[:scenarios].empty?
      flash[:error] = "No orders created"
    else
      @orders = Cdf::OrderBuilder.create_for_scenarios params[:scenarios]
      flash[:notice] = "Created #{@orders.count} test orders"      
    end
    
    redirect_to :action => :order_check
  end
  
  def ftp_check
    client = CdfFtpClient.new({:keep_alive => true})
    @valid_server = client.valid_server?
    @valid_credentials = client.valid_credentials?
    if @valid_credentials
      @outgoing_files = client.outgoing_files
      @test_files = client.test_files
      @archive_files = client.archive_files
      @incoming_files = client.archive_files
    end
    client.close

    # check the inventory server - always going against the live server
    client_inventory = CdfFtpClient.new({:keep_alive => true,
                                         :server => Cdf::Config[:cdf_ftp_inventory_server],
                                         :user => Cdf::Config[:cdf_ftp_inventory_user],
                                         :password => Cdf::Config[:cdf_ftp_inventory_password],
                                         :run_mode => :live })
    @valid_inventory_server = client_inventory.valid_server?
    @valid_inventory_credentials = client_inventory.valid_credentials?
    client_inventory.close

  end

end
