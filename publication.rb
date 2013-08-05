require "sinatra"
require "simple_xurrency"
require "active_support/core_ext/integer/inflections"

supported_curr = [:eur, :usd, :gbp, :aud, :brl, :cad, :chf, :cny, :dkk, :hkd, :inr, :jpy, :krw,
                 :lkr, :myr, :nzd, :sgd, :twd, :zar, :thb, :sek, :nok, :mxn, :bgn, :czk, :huf,
                 :ltl, :lvl, :pln, :ron, :isk, :hrk, :rub, :try, :php, :cop, :ars, :clp, :svc,
                 :tnd, :pyg, :mad, :jmd, :sar, :qar, :hnl, :syp, :kwd, :bhd, :egp, :omr, :ngn,
                 :pab, :pen, :uyu]

popular_curr = [:eur, :usd, :gbp, :aud, :brl, :cad, :chf, :cny, :dkk, :hkd, :inr, :jpy, :krw]

SimpleXurrency.key="a68f78dfde1be099be24543b7096a838"

get "/edition/" do
  # Fetch preferred currency
  # Fetch datetime.
  # Xurrency object
  # For top currs (except chosen)
    # Get rate and inverse
  # eTag with updated_at from Xurrency

  currency = params[:currency]
  @rates = []

  if supported_curr.include?(currency.to_sym)
    popular_curr.each do |pc|
      unless pc.to_s == currency.to_s
        @rates << [1.send(currency).send("to_#{pc}"),
                   1.send(pc).send("to_#{currency}"),
                   1.send(currency).send("to_#{pc}_updated_at")]
      end
    end
  end

  content_type "text/html; charset=utf-8"
  etag Digest::MD5.hexdigest(Time.now.to_i.to_s)
  erb :rates
end

get "/sample/" do
  content_type "text/html; charset=utf-8"
  etag Digest::MD5.hexdigest(Time.now.to_i.to_s)
  erb :rates
end

get "/validate_config/" do
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
  
  unless supported_curr.include?(user_settings["currency"].downcase)
    response[:valid] = false
    response[:errors].push("We couldn't find the currency you selected (#{user_settings["currency"]}). Please select another.")
  end
  
  content_type :json
  response.to_json
end
