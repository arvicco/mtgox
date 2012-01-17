require 'helper'
require 'json'

describe 'Models as used by MtGox streaming (String.io) API' do

  describe MtGox::Models::Depth do
    before do
      @data = JSON.parse(fixture('io-depth.json').read)['depth']
    end

    it "should create Depth change model from data Hash" do
      depth = MtGox::Models::Depth.new @data

      depth.price.should == 6.77763
      depth.price_int.should == 677763
      depth.volume.should == 0.0533162
      depth.volume_int.should == 5331620
      depth.type.should == :bid
      depth.item.should == 'BTC'
      depth.currency.should == 'USD'
      depth.total_volume_int.should == 5331620
      depth.id.should == 1326807285171878
      depth.now.should == 1326807285171878
    end
  end

  describe MtGox::Models::MultiTicker do
    before do
      @data = JSON.parse(fixture('io-ticker.json').read)['ticker']
    end

    it "should create MultiTicker from data Hash" do
      ticker = MtGox::Models::MultiTicker.new @data

      ticker.price.should == 6.78799
      ticker.last.should == 6.78799
      ticker.last_local.should == 6.78799
      ticker.last_orig.should == 6.78799
      ticker.last_all.should == 6.78799
      ticker.high.should == 7.09000
      ticker.low.should == 6.511
      ticker.avg.should == 6.72804
      ticker.vwap.should == 6.71887
      ticker.buy.should == 6.76722
      ticker.sell.should == 6.77000
      ticker.volume.should == 107798.84280561
      #ticker.currency.should == 'USD'
    end
  end
end
