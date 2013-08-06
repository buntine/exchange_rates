require "sinatra"
require "date"
require "json"
require "simple_xurrency"
require "active_support/core_ext/integer/inflections"

$supported_curr = [:eur, :usd, :gbp, :aud, :brl, :cad, :chf, :cny, :dkk, :hkd, :inr, :jpy, :krw,
                  :lkr, :myr, :nzd, :sgd, :twd, :zar, :thb, :sek, :nok, :mxn, :bgn, :czk, :huf,
                  :ltl, :lvl, :pln, :ron, :isk, :hrk, :rub, :try, :php, :cop, :ars, :clp, :svc,
                  :tnd, :pyg, :mad, :jmd, :sar, :qar, :hnl, :syp, :kwd, :bhd, :egp, :omr, :ngn,
                  :pab, :pen, :uyu]

$popular_curr = [:eur, :usd, :gbp, :aud, :brl, :cad, :chf, :cny, :dkk, :hkd, :inr, :jpy]

SimpleXurrency.key = "API_KEY"

helpers do
  def build_rates(curr)
    @currency = curr
    @rates = []
  
    if $supported_curr.include?(@currency.to_sym)
      $popular_curr.each do |pc|
        unless pc.to_s == @currency.to_s
          rate = 1.send(@currency).send("to_#{pc}")
          @rates << [pc, rate, (1.0 / rate).round(4)]
        end
      end
  
      @local_time = if params[:local_delivery_time]
        Time.parse(params[:local_delivery_time])
      else
        Time.now
      end
  
      @updated_at = Time.parse(1.send(@currency).send("to_#{$popular_curr.first}_updated_at")) - (60 * 60)
  
      true
    end
  end
end

get "/edition/" do
  curr = if not params[:test]
    return 400, "Error: No local_delivery_time was provided" if params[:local_delivery_time].nil?
    return 400, "Error: No currency was provided" if params[:currency].nil?

    params[:currency]
  else
    "usd"
  end

  if not build_rates(curr)
    return 400, "Error: Invalid currency was provided"
  end

  content_type "text/html; charset=utf-8"
  etag Digest::MD5.hexdigest(curr + @updated_at.to_s)
  erb :rates
end

get "/sample/" do
  if not build_rates("usd")
    return 400, "Error: Invalid currency was provided"
  end

  content_type "text/html; charset=utf-8"
  etag Digest::MD5.hexdigest(@currency + @updated_at.to_s)
  erb :rates
end

post "/validate_config/" do
  response = {}
  response[:errors] = []
  response[:valid] = true
  
  if params[:config].nil?
    return 400, "You did not post any config to validate"
  end

  user_settings = JSON.parse(params[:config])

  if user_settings["currency"].nil? || user_settings["currency"] == ""
    response[:valid] = false
    response[:errors].push("Please select a currency from the select box.")
  end
  
  unless $supported_curr.include?(user_settings["currency"].downcase.to_sym)
    response[:valid] = false
    response[:errors].push("We couldn't find the currency you selected (#{user_settings["currency"]}). Please select another.")
  end
  
  content_type :json
  response.to_json
end
