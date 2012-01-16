# Ruby wrapper for the Mt. Gox Trade API.

## <a name="fork"></a>This Fork
This fork is a rework of original business domain entities into new Models, with
an intent to make these Models ActiveModel-compliant in future.

## <a name="installation"></a>Installation
    gem install mt_gox

## <a name="alias"></a>Alias
After installing the gem, you can get the current price for 1 BTC in USD by
typing `btc` in your bash shell simply by setting the following alias:

    alias btc='ruby -r rubygems -r mtgox -e "puts MtGox.ticker.sell"'

## <a name="examples"></a>Usage Examples
    require 'rubygems'
    require 'mtgox'

    # Fetch the latest price for 1 BTC in USD
    puts MtGox.ticker.sell

    # Fetch open asks
    puts MtGox.asks

    # Fetch open bids
    puts MtGox.bids

    # Fetch the last 48 hours worth of trades (takes a minute)
    puts MtGox.trades

    # Certain methods require authentication
    MtGox.configure do |config|
      config.key = YOUR_MTGOX_KEY
      config.secret = YOUR_MTGOX_SECRET
    end

    # Fetch your current balance
    puts MtGox.balance

    # Place a limit order to buy one bitcoin for $0.011
    MtGox.buy! 1.0, 0.011

    # Place a limit order to sell one bitcoin for $100
    MtGox.sell! 1.0, 100.0

    # Cancel order #1234567890
    MtGox.cancel 1234567890

    # Withdraw 1 BTC from your account
    MtGox.withdraw! 1.0, "1KxSo9bGBfPVFEtWNLpnUK1bfLNNT4q31L"

[issues]: https://github.com/arvicco/mtgox/issues

## <a name="copyright"></a>Copyright
Copyright (c) 2011 Erik Michaels-Ober.
Copyright (c) 2012 Arvicco (extension).

See [LICENSE][] for details.

[license]: https://github.com/sferik/mtgox/blob/master/LICENSE.md
