require 'helper'

describe MtGox::Client do
  before do
    @client = MtGox::Client.new
    MtGox.configure do |config|
      config.key = "key"
      config.secret = "secret"
    end
  end

  describe '#address' do
    before do
      stub_post('/api/0/btcAddress.php').
          to_return(:status => 200, :body => fixture('address.json'))
    end

    it "should fetch a deposit address" do
      address = @client.address
      a_post('/api/0/btcAddress.php').
          should have_been_made
      address.should == '171dH9Uum6wWLSwH2g8g2yto6SG7NEGyXG'
    end
  end

  describe '#ticker' do
    before do
      #WebMock.allow_net_connect!
      stub_get('/api/0/data/ticker.php').
          to_return(:status => 200, :body => fixture('ticker.json'))
    end

    it "should fetch the ticker" do
      ticker = @client.ticker
      a_get('/api/0/data/ticker.php').should have_been_made
      ticker.buy.should == 6.6809
      ticker.sell.should == 6.69803
      ticker.high.should == 6.95
      ticker.low.should == 6.4501
      ticker.price.should == 6.69
      ticker.last_all.should == 6.69
      ticker.last_local.should == 6.69
      ticker.volume.should == 113312
      ticker.avg.should == 6.691234882
      ticker.vwap.should == 6.668617425
    end

    it 'keeps track of consecutive ticker readings' do
      ticker = @client.ticker
      ticker = @client.ticker
      ticker.should be_unchanged
      ticker.should_not be_changed
      ticker.should_not be_up
      ticker.should_not be_down

      # Now changed
      stub_get('/api/0/data/ticker.php').
          to_return(:status => 200, :body => fixture('ticker1.json'))
      ticker = @client.ticker
      ticker.should_not be_unchanged
      ticker.should be_changed
      ticker.should be_up
      ticker.should_not be_down

      a_get('/api/0/data/ticker.php').should have_been_made.times(3)
    end
  end

  describe '#ticker(currency)' do
    before do
      stub_get('/api/1/BTCEUR/public/ticker').
          to_return(:status => 200, :body => fixture('multi-ticker.json'))
    end

    it "should fetch the multi-currency ticker" do
      ticker = @client.ticker('EUR')
      a_get('/api/1/BTCEUR/public/ticker').should have_been_made
      ticker.buy.should == 5.340
      ticker.sell.should == 5.350
      ticker.high.should == 5.500
      ticker.low.should == 5.12541
      ticker.price.should == 5.340
      ticker.last.should == 5.340
      ticker.last_local.should == 5.340
      ticker.last_orig.should == 6.65001 # "currency":"USD"
      ticker.last_all.should == 5.24904 # ?
      ticker.volume.should == 1277.68857150
      ticker.avg.should == 5.31551
      ticker.vwap.should == 5.29709
      ticker.currency.should == 'EUR'
    end

    it 'keeps track of consecutive ticker readings' do
      ticker = @client.ticker('EUR')
      ticker = @client.ticker('EUR')
      ticker.should be_unchanged
      ticker.should_not be_changed
      ticker.should_not be_up
      ticker.should_not be_down

      # Now changed
      stub_get('/api/1/BTCEUR/public/ticker').
          to_return(:status => 200, :body => fixture('multi-ticker1.json'))
      ticker = @client.ticker('EUR')
      ticker.should_not be_unchanged
      ticker.should be_changed
      ticker.should be_up
      ticker.should_not be_down

      a_get('/api/1/BTCEUR/public/ticker').should have_been_made.times(3)
    end
  end

  describe 'depth methods' do
    before :each do
      stub_get('/api/0/data/getDepth.php').
          to_return(:status => 200, :body => fixture('depth.json'))
    end

    describe '#asks' do
      it "should fetch open asks" do
        asks = @client.asks
        a_get('/api/0/data/getDepth.php').should have_been_made
        asks.last.price.should == 23.75
        asks.last.eprice.should == 23.905385002516354
        asks.last.amount.should == 50
      end

      it "should be sorted in price-ascending order" do
        asks = @client.asks
        asks.sort_by { |ask| ask.price }.should == asks
      end

    end

    describe "#bids" do
      it "should fetch open bids" do
        bids = @client.bids
        a_get('/api/0/data/getDepth.php').should have_been_made
        bids.last.price.should == 14.62101
        bids.last.eprice.should == 14.525973435000001
        bids.last.amount.should == 5
      end

      it "should be sorted in price-descending order" do
        bids = @client.bids
        bids.sort_by { |bid| bid.price }.reverse.should == bids
      end
    end

    describe "#offers" do
      it "should fetch (short version) of bids and asks by default" do
        offers = @client.offers
        a_get('/api/0/data/getDepth.php').should have_been_made.once
        offers[:asks].last.price.should == 23.75
        offers[:asks].last.eprice.should == 23.905385002516354
        offers[:asks].last.amount.should == 50
        offers[:bids].last.price.should == 14.62101
        offers[:bids].last.eprice.should == 14.525973435000001
        offers[:bids].last.amount.should == 5
      end

      it "should fetch bids/asks in extended form with #offers(true)" do
        pending 'Stubs!'
        offers = @client.offers(true)
        a_get('/api/0/data/getDepth.php').should have_been_made.once
        offers[:asks].last.price.should == 23.75
        offers[:asks].last.eprice.should == 23.905385002516354
        offers[:asks].last.amount.should == 50
        offers[:bids].last.price.should == 14.62101
        offers[:bids].last.eprice.should == 14.525973435000001
        offers[:bids].last.amount.should == 5
      end
    end

    describe '#min_ask' do
      it "should fetch the lowest priced ask" do
        min_ask = @client.min_ask
        a_get('/api/0/data/getDepth.php').should have_been_made.once
        min_ask.price.should == 17.00009
        min_ask.eprice.should == 17.11131353799698
        min_ask.amount.should == 36.22894353
      end
    end

    describe '#max_bid' do
      it "should fetch the highest priced bid" do
        max_bid = @client.max_bid
        a_get('/api/0/data/getDepth.php').should have_been_made.once
        max_bid.price.should == 17.0
        max_bid.eprice.should == 16.8895
        max_bid.amount.should == 82.53875035
      end
    end

  end

  describe '#trades' do
    before do
      stub_get('/api/0/data/getTrades.php').
          to_return(:status => 200, :body => fixture('trades.json'))
    end

    it "should fetch trades" do
      trades = @client.trades
      a_get('/api/0/data/getTrades.php').should have_been_made
      trades.last.date.should == Time.utc(2011, 6, 27, 18, 28, 8)
      trades.last.price.should == 17.00009
      trades.last.amount.should == 0.5
      trades.last.id.should == 1309199288687054
    end
  end

  describe '#balance' do
    before do
      stub_post('/api/0/getFunds.php').
          with(:body => test_body, :headers => test_headers).
          to_return(:status => 200, :body => fixture('balance.json'))
    end

    it "should fetch balance" do
      balance = @client.balance
      a_post("/api/0/getFunds.php").
          with(:body => test_body, :headers => test_headers).should have_been_made
      balance.first.currency.should == "BTC"
      balance.first.amount.should == 22.0
      balance.last.currency.should == "USD"
      balance.last.amount.should == 3.7
    end
  end

  describe "order methods" do
    before :each do
      stub_post('/api/0/getOrders.php').
          with(:body => test_body, :headers => test_headers).
          to_return(:status => 200, :body => fixture('orders.json'))
    end

    describe "#buys" do
      it "should fetch orders" do
        buys = @client.buys
        a_post("/api/0/getOrders.php").
            with(:body => test_body, :headers => test_headers).should have_been_made
        buys.last.price.should == 7
        buys.last.date.should == Time.utc(2011, 6, 27, 18, 20, 38)
      end
    end

    describe "#sells" do
      it "should fetch sells" do
        sells = @client.sells
        a_post("/api/0/getOrders.php").
            with(:body => test_body, :headers => test_headers).should have_been_made
        sells.last.price.should == 99.0
        sells.last.date.should == Time.utc(2011, 6, 27, 18, 20, 20)
      end
    end

    describe "#orders" do
      it "should fetch both buys and sells, with only one call" do
        orders = @client.orders
        a_post("/api/0/getOrders.php").
            with(:body => test_body, :headers => test_headers).should have_been_made
        orders[:buys].last.price.should == 7.0
        orders[:buys].last.date.should == Time.utc(2011, 6, 27, 18, 20, 38)
        orders[:sells].last.price.should == 99.0
        orders[:sells].last.date.should == Time.utc(2011, 6, 27, 18, 20, 20)
      end
    end
  end

  describe "#buy!" do
    before do
      body = test_body({"amount" => "0.88", "price" => "0.89"})
      stub_post('/api/0/buyBTC.php').
          with(:body => body, :headers => test_headers(body)).
          to_return(:status => 200, :body => fixture('buy.json'))
    end

    it "should place a bid" do
      buy = @client.buy!(0.88, 0.89)
      body = test_body({"amount" => "0.88", "price" => "0.89"})
      a_post("/api/0/buyBTC.php").
          with(:body => body, :headers => test_headers(body)).should have_been_made
      buy[:buys].last.price.should == 2.0
      buy[:buys].last.date.should == Time.utc(2011, 6, 27, 18, 26, 21)
      buy[:sells].last.price.should == 99.0
      buy[:sells].last.date.should == Time.utc(2011, 6, 27, 18, 20, 20)
    end
  end

  describe "#sell!" do
    before do
      body = test_body({"amount" => "0.88", "price" => "89.0"})
      stub_post('/api/0/sellBTC.php').
          with(:body => body, :headers => test_headers(body)).
          to_return(:status => 200, :body => fixture('sell.json'))
    end

    it "should place an ask" do
      body = test_body({"amount" => "0.88", "price" => "89.0"})
      sell = @client.sell!(0.88, 89.0)
      a_post("/api/0/sellBTC.php").
          with(:body => body, :headers => test_headers(body)).should have_been_made
      sell[:buys].last.price.should == 2.0
      sell[:buys].last.date.should == Time.utc(2011, 6, 27, 18, 26, 21)
      sell[:sells].last.price.should == 200
      sell[:sells].last.date.should == Time.utc(2011, 6, 27, 18, 27, 54)
    end
  end

  describe "#cancel" do
    before do
      cancel_body = test_body({"oid" => "bddd042c-e837-4a88-a92e-3b7c05e483df", "type" => "2"})
      stub_post('/api/0/getOrders.php').
          with(:body => test_body, :headers => test_headers).
          to_return(:status => 200, :body => fixture('orders.json'))
      stub_post('/api/0/cancelOrder.php').
          with(:body => cancel_body, :headers => test_headers(cancel_body)).
          to_return(:status => 200, :body => fixture('cancel.json'))
    end

    context "with a valid oid passed" do
      it "should cancel an order" do
        cancel = @client.cancel("bddd042c-e837-4a88-a92e-3b7c05e483df")
        cancel_body = test_body({"oid" => "bddd042c-e837-4a88-a92e-3b7c05e483df", "type" => "2"})
        a_post("/api/0/getOrders.php").
            with(:body => test_body, :headers => test_headers).
            should have_been_made.once
        a_post('/api/0/cancelOrder.php').
            with(:body => cancel_body, :headers => test_headers(cancel_body)).
            should have_been_made
        cancel[:buys].last.price.should == 7.0
        cancel[:buys].last.date.should == Time.utc(2011, 6, 27, 18, 20, 38)
        cancel[:sells].last.price.should == 99.0
        cancel[:sells].last.date.should == Time.utc(2011, 6, 27, 18, 20, 20)
      end
    end

    context "with an invalid oid passed" do
      it "should raise an error" do
        lambda do
          @client.cancel(1234567890)
        end.should raise_error(Faraday::Error::ResourceNotFound)
      end
    end

    context "with an order passed" do
      it "should cancel an order" do
        cancel = @client.cancel({'oid' => "bddd042c-e837-4a88-a92e-3b7c05e483df", 'type' => 2})
        body = test_body({"oid" => "bddd042c-e837-4a88-a92e-3b7c05e483df", "type" => "2"})
        a_post('/api/0/cancelOrder.php').
            with(:body => body, :headers => test_headers(body)).should have_been_made
        cancel[:buys].last.price.should == 7.0
        cancel[:buys].last.date.should == Time.utc(2011, 6, 27, 18, 20, 38)
        cancel[:sells].last.price.should == 99.0
        cancel[:sells].last.date.should == Time.utc(2011, 6, 27, 18, 20, 20)
      end
    end
  end

  describe "#withdraw!" do
    before do
      body = test_body({"group1" => "BTC", "amount" => "1.0", "btca" => "1KxSo9bGBfPVFEtWNLpnUK1bfLNNT4q31L"})
      stub_post('/api/0/withdraw.php').
          with(:body => body, :headers => test_headers(body)).
          to_return(:status => 200, :body => fixture('withdraw.json'))
    end

    it "should withdraw funds" do
      withdraw = @client.withdraw!(1.0, "1KxSo9bGBfPVFEtWNLpnUK1bfLNNT4q31L")
      body = test_body({"group1" => "BTC", "amount" => "1.0", "btca" => "1KxSo9bGBfPVFEtWNLpnUK1bfLNNT4q31L"})
      a_post("/api/0/withdraw.php").
          with(:body => body, :headers => test_headers(body)).should have_been_made
      withdraw['status'].should =~ /Funds are on their way/
      withdraw['reference'].should == "d576535c-68a9-4ecc-b7fb-9ea18dd0367c"
    end

  end

  describe "#withdraw_raw!" do
    before do
      body = test_body({"group1" => "BTC", "amount" => "1.0", "btca" => "1KxSo9bGBfPVFEtWNLpnUK1bfLNNT4q31L"})
      stub_post('/api/0/withdraw.php').
          with(:body => body, :headers => test_headers(body)).
          to_return(:status => 200, :body => fixture('withdraw.json'))
    end

    it "should withdraw to BTC address by default" do
      withdraw = @client.withdraw_raw!(:amount => 1.0,
                                       :address => "1KxSo9bGBfPVFEtWNLpnUK1bfLNNT4q31L")
      body = test_body({"group1" => "BTC", "amount" => "1.0", "btca" => "1KxSo9bGBfPVFEtWNLpnUK1bfLNNT4q31L"})
      a_post("/api/0/withdraw.php").
          with(:body => body, :headers => test_headers(body)).should have_been_made
      withdraw['status'].should =~ /Funds are on their way/
      withdraw['reference'].should == "d576535c-68a9-4ecc-b7fb-9ea18dd0367c"
    end

    it "should withdraw to Dwolla" do
      body1 = test_body({"group1" => 'DWUSD', "amount" => "1.0", 'dwaccount' => "111-222-3333"})
      stub_post('/api/0/withdraw.php').
          with(:body => body1, :headers => test_headers(body1)).
          to_return(:status => 200, :body => fixture('withdraw_dwolla.json'))

      withdraw = @client.withdraw_raw!(:group1 => 'DWUSD',
                                       :amount => 1.0,
                                       :address => "111-222-3333")
      a_post("/api/0/withdraw.php").
          with(:body => body1, :headers => test_headers(body1)).should have_been_made
      withdraw['error'].should =~ /Invalid Dwolla account/
    end

    it "should withdraw to BTC coupon" do
      body1 = test_body({"group1" => 'BTC2CODE', "amount" => "0.5"})
      stub_post('/api/0/withdraw.php').
          with(:body => body1, :headers => test_headers(body1)).
          to_return(:status => 200, :body => fixture('withdraw_btc_code.json'))

      withdraw = @client.withdraw_raw!(:amount => 0.5, :group1 => 'BTC2CODE')
      a_post("/api/0/withdraw.php").
          with(:body => body1, :headers => test_headers(body1)).should have_been_made

      withdraw['code'].should == "MTGOX-BTC-5LHXF-58CFB-RBR9Z-46C57"
      withdraw['status'].should =~ /Generated new code/
      withdraw['reference'].should == "00c64004-6bbb-4fdc-a026-2cda492aae63"
    end

    it "should withdraw to USD coupon" do
      body1 = test_body({"group1" => 'USD2CODE', "amount" => "0.5"})
      stub_post('/api/0/withdraw.php').
          with(:body => body1, :headers => test_headers(body1)).
          to_return(:status => 200, :body => fixture('withdraw_usd_code.json'))

      withdraw = @client.withdraw_raw!(:amount => 0.5, :group1 => 'USD2CODE')
      a_post("/api/0/withdraw.php").
          with(:body => body1, :headers => test_headers(body1)).should have_been_made

      withdraw['code'].should == "MTGOX-USD-GJG9B-GZST8-EDMAS-800FB"
      withdraw['status'].should =~ /Generated new code/
      withdraw['reference'].should == "1745595c-db09-4f26-9f12-8057a71c3031"
    end
  end

  describe "#redeem_code!" do
    before do
      @body = test_body({"code" => "MTGOX-BTC-5LHXF-58CFB-RBR9Z-46C57"})
      stub_post('/api/0/redeemCode.php').
          with(:body => @body, :headers => test_headers(@body)).
          to_return(:status => 200, :body => fixture('redeem_btc_code.json'))
    end

    it "should withdraw to BTC address by default" do
      redeem = @client.redeem_code!("MTGOX-BTC-5LHXF-58CFB-RBR9Z-46C57")
      a_post('/api/0/redeemCode.php').
          with(:body => @body, :headers => test_headers(@body)).should have_been_made

      redeem['amount'].should == 0.5
      redeem['currency'].should == "BTC"
      redeem['status'].should =~ /Your account has been credited by/
      redeem['reference'].should == "1cb21630-cf7d-40e4-8f72-7a6e6c2792d0"
    end
  end
end
