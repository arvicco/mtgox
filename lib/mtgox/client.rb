require 'faraday/error'
require 'mtgox/connection'
require 'mtgox/request'

module MtGox
  class Client
    include MtGox::Connection
    include MtGox::Request
    include MtGox::Models

    ORDER_TYPES = {:sell => 1, :buy => 2}

    # Using class variables instead of Singleton
    @@ticker = {}
    @@min_ask = MinAsk.new []
    @@max_bid = MaxBid.new []

    # Fetch a deposit address
    # @authenticated true
    # @return [String]
    # @example
    #   MtGox.address
    def address
      post('/api/0/btcAddress.php')['addr']
    end

    # Fetch a MtGox executions for a given order
    # @authenticated true
    # @return [String]
    # @example
    #   MtGox.executions
    def executions order_id, order_type = 'bid' # 'ask'
      res = post('/api/1/generic/private/order/result',
                 :order => order_id,
                 :type => order_type)
    end

    # Fetch a MtGox private info
    # @authenticated true
    # @return [String]
    # @example
    #   MtGox.private_info
    def private_info symbol = 'USD'
      #res = post("/api/0/info.php")
      res = post("https://mtgox.com/api/1/generic/private/info")
      res["result"] == "success" ? res["return"] : res
    end

    # Fetch a MtGox currency info
    # @return [String]
    # @example
    #   MtGox.currency_info
    def currency_info symbol = 'USD'
      res = get("/api/1/generic/public/currency?currency=#{symbol}")
      res["result"] == "success" ? res["return"] : res
    end

    # Fetch the latest ticker data
    #
    # @authenticated false
    # @return [MtGox::Ticker]
    # @example
    #   MtGox.ticker
    #   MtGox.ticker('EUR')
    def ticker(currency=nil)
      if currency
        ticker = get("/api/1/BTC#{currency}/public/ticker")['return']
        @@ticker[currency] ||= MultiTicker.new :currency => currency
        @@ticker[currency].set_attributes ticker
      else
        ticker = get('/api/0/data/ticker.php')['ticker']
        @@ticker['USD'] ||= Ticker.new
        @@ticker['USD'].set_attributes ticker
      end
    end

    # Fetch both bids and asks in one call, for network efficiency
    #
    # @authenticated false
    # @return [Hash] with keys :asks and :asks, which contain arrays as described in {MtGox::Client#asks} and {MtGox::Clients#bids}
    # @example
    #   MtGox.offers
    def offers full=false
      offers = full ?
          get('/api/1/BTCUSD/public/fulldepth')['return'] :
          get('/api/0/data/getDepth.php')
      asks = offers['asks'].map { |ask| Ask.new(ask) }.sort_by(&:price) # TODO: Comparable ?
      bids = offers['bids'].map { |bid| Bid.new(bid) }.sort_by { |bid| -bid.price }
      {:asks => asks, :bids => bids}
    end

    # Fetch open asks
    #
    # @authenticated false
    # @return [Array<MtGox::Ask>] an array of open asks, sorted in price ascending order
    # @example
    #   MtGox.asks
    def asks
      offers[:asks]
    end

    # Fetch open bids
    #
    # @authenticated false
    # @return [Array<MtGox::Bid>] an array of open bids, sorted in price descending order
    # @example
    #   MtGox.bids
    def bids
      offers[:bids]
    end

    # Fetch the lowest priced ask
    #
    # @authenticated false
    # @return [MtGox::MinAsk]
    # @example
    #   MtGox.min_ask
    def min_ask
      @@min_ask.set_attributes asks.first.attributes
    end

    # Fetch the highest priced bid
    #
    # @authenticated false
    # @return [MtGox::MaxBid]
    # @example
    #   MtGox.max_bid
    def max_bid
      @@max_bid.set_attributes bids.first.attributes
    end

    # Fetch recent trades
    #
    # @authenticated false
    # @return [Array<MtGox::Trade>] an array of trades, sorted in chronological order
    # @example
    #   MtGox.trades
    def trades
      get('/api/0/data/getTrades.php').sort_by { |trade| trade['date'] }.map do |trade|
        Trade.new(trade)
      end
    end

    # Fetch your current balance
    #
    # @authenticated true
    # @return [Array<MtGox::Balance>]
    # @example
    #   MtGox.balance
    def balance
      parse_balance(post('/api/0/getFunds.php', {}))
      #info = post('/code/info.php', pass_params)
      #info['Wallets'].values.map { |v| v['Balance'] }.map do |balance_info|
      #  Balance.new(balance_info['currency'], balance_info['value'])
      #end
    end

    # Fetch your open orders, both buys and sells, for network efficiency
    #
    # @authenticated true
    # @return [Hash] with keys :buys and :sells, which contain arrays as described in {MtGox::Client#buys} and {MtGox::Clients#sells}
    # @example
    #   MtGox.orders
    def orders
      parse_orders(post('/api/0/getOrders.php', {})['orders'])
    end

    # Fetch your open buys
    #
    # @authenticated true
    # @return [Array<MtGox::Buy>] an array of your open bids, sorted by date
    # @example
    #   MtGox.buys
    def buys
      orders[:buys]
    end

    # Fetch your open sells
    #
    # @authenticated true
    # @return [Array<MtGox::Sell>] an array of your open asks, sorted by date
    # @example
    #   MtGox.sells
    def sells
      orders[:sells]
    end

    # Place a limit order to buy BTC
    #
    # @authenticated true
    # @param amount [Numeric] the number of bitcoins to purchase
    # @param price [Numeric] the bid price in US dollars
    # @return [Hash] with keys :buys and :sells, which contain arrays as described in {MtGox::Client#buys} and {MtGox::Clients#sells}
    # @example
    #   # Buy one bitcoin for $0.011
    #   MtGox.buy! 1.0, 0.011
    def buy!(amount, price)
      parse_orders(post('/api/0/buyBTC.php', {:amount => amount, :price => price})['orders'])
    end

    # Place a limit order to sell BTC
    #
    # @authenticated true
    # @param amount [Numeric] the number of bitcoins to sell
    # @param price [Numeric] the ask price in US dollars
    # @return [Hash] with keys :buys and :sells, which contain arrays as described in {MtGox::Client#buys} and {MtGox::Clients#sells}
    # @example
    #   # Sell one bitcoin for $100
    #   MtGox.sell! 1.0, 100.0
    def sell!(amount, price)
      parse_orders(post('/api/0/sellBTC.php', {:amount => amount, :price => price})['orders'])
    end

    # Cancel an open order
    #
    # @authenticated true
    # @overload cancel(oid)
    #   @param oid [String] an order ID
    #   @return [Hash] with keys :buys and :sells, which contain arrays as described in {MtGox::Client#buys} and {MtGox::Clients#sells}
    #   @example
    #     my_order = MtGox.orders.first
    #     MtGox.cancel my_order.oid
    #     MtGox.cancel 1234567890
    # @overload cancel(order)
    #   @param order [Hash] a hash-like object, with keys `oid` - the order ID of the transaction to cancel and `type` - the type of order to cancel (`1` for sell or `2` for buy)
    #   @return [Hash] with keys :buys and :sells, which contain arrays as described in {MtGox::Client#buys} and {MtGox::Clients#sells}
    #   @example
    #     my_order = MtGox.orders.first
    #     MtGox.cancel my_order
    #     MtGox.cancel {'oid' => '1234567890', 'type' => 2}
    def cancel(args)
      if args.is_a?(Hash)
        order = args.delete_if { |k, v| !['oid', 'type'].include?(k.to_s) }
        parse_orders(post('/api/0/cancelOrder.php', order)['orders'])
      else
        orders = post('/api/0/getOrders.php', {})['orders']
        order = orders.find { |order| order['oid'] == args.to_s }
        if order
          order = order.delete_if { |k, v| !['oid', 'type'].include?(k.to_s) }
          parse_orders(post('/api/0/cancelOrder.php', order)['orders'])
        else
          raise Faraday::Error::ResourceNotFound, {:status => 404, :headers => {}, :body => 'Order not found.'}
        end
      end
    end

    ## Work with Mt. Gox accounts

    # Transfer bitcoins from your Mt. Gox account into another account
    #
    # @authenticated true
    # @param amount [Numeric] the number of bitcoins to withdraw
    # @param address [String] the bitcoin address to send to
    # @return {"status"=> "Message", "reference"=>"uuid"}
    # @example
    #   # Withdraw 1 BTC from your account
    #   MtGox.withdraw! 1.0, '1KxSo9bGBfPVFEtWNLpnUK1bfLNNT4q31L'
    def withdraw! amount, address
      post('/api/0/withdraw.php', {:group1 => 'BTC', :amount => amount, :btca => address})
    end

    # Transfer bitcoins from your Mt. Gox account (raw params given)
    #
    # @authenticated true
    #   @opt amount [Numeric] the number of bitcoins to withdraw
    #   @opt address [String] the bitcoin address to send to
    #   @opt green [Numeric] =1 to use greenaddress feature ( see GreenAddress )
    #   @opt dwaccount [String] account for a dwolla withdraw XXX-XXX-XXXX (no btca=xxxxxxx!)
    #   @opt group1 [String] BTC - for BTC address withdraw
    #                        BTC2CODE for BTC coupon withdraw
    #                        USD2CODE add a Currency parameter ( example Currency=EUR to get a mtgox EUR coupon )
    #                        DWUSD for Dwolla withdraw
    #   @opt Currency [String] add to get specific currency coupons with group1=USD2CODE
    #                          (example group1=USD2CODE&Currency=EUR for Mtgox EUR coupons)
    # @return [Array<MtGox::Balance>]
    # @example
    #   # Withdraw 1 BTC from your account
    #   MtGox.withdraw! 1.0, '1KxSo9bGBfPVFEtWNLpnUK1bfLNNT4q31L'
    def withdraw_raw! params_raw
      params = {}
      params[:group1] = params_raw.delete(:group1) || params_raw.delete(:group) || 'BTC'
      params[:amount] = params_raw.delete(:amount)
      raise "Withdrawal params should have :amount" unless params[:amount]
      case params[:group1]
        when 'BTC' # BTC withdrawal by default
          params[:btca] = params_raw.delete(:address) || params_raw.delete(:btca)
          raise "Wrong BTC address" unless params[:btca] =~ /[a-zA-Z1-9]{27,35}$/
          post('/api/0/withdraw.php', params.merge(params_raw))
        when 'DWUSD'
          params[:dwaccount] = params_raw.delete(:address) ||
              params_raw.delete(:account) || params_raw.delete(:dwaccount)
          raise "Wrong Dwolla address" unless params[:dwaccount] =~ /\d{3}-\d{3}-\d{4}$/
          post('/api/0/withdraw.php', params.merge(params_raw))
        when 'BTC2CODE', 'USD2CODE'
          post('/api/0/withdraw.php', params.merge(params_raw))
        else
          post('/api/0/withdraw.php', params.merge(params_raw))
      end
    end

    # Redeem MtGox code
    #
    # @authenticated true
    # @param code [String] coupon code to redeem
    # @return [Array<MtGox::Balance>]
    def redeem_code!(code)
      post('/api/0/redeemCode.php', :code => code)
    end

    private

    def parse_balance(balance)
      balances = []
      balances << Balance.new(:currency => 'BTC', :amount => balance['btcs'])
      balances << Balance.new(:currency => 'USD', :amount => balance['usds'])
      balances
    end

    def parse_orders(orders)
      buys = []
      sells = []
      orders.sort_by { |order| order['date'] }.each do |order|
        case order['type']
          when ORDER_TYPES[:sell]
            sells << Sell.new(order)
          when ORDER_TYPES[:buy]
            buys << Buy.new(order)
        end
      end
      {:buys => buys, :sells => sells}
    end
  end
end
