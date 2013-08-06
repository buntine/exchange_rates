require "sinatra"
require "date"
require "json"
require "simple_xurrency"
require "active_support/core_ext/integer/inflections"


SimpleXurrency.key = "a68f78dfde1be099be24543b7096a838"

helpers do
  @@supported_curr = {:eur => "Euro", :usd => "United States Dollar", :gbp => "Pound Sterling", :aud => "Australian Dollar",
                      :brl => "Brazilian Real", :cad => "Canadian Dollar", :chf => "Swiss Franc", :cny => "Chinese Yuan",
                      :dkk => "Danish Krone", :hkd => "Hong Kong Dollar", :inr => "Indian Rupee", :jpy => "Japanese Yen",
                      :krw => "Korea Won", :lkr => "Sri Lanka Rupee", :myr => "Malasian Ringgit", :nzd => "New Zealand Dollar",
                      :sgd => "Singapore Dollar", :twd => "Taiwan Dollar", :zar => "South Africa Rand", :thb => "Thailand Baht",
                      :sek => "Swedish Krona", :nok => "Norwegian Krone", :mxn => "Mexican Peso", :bgn => "Bulgarian Lev",
                      :czk => "Czech Koruna", :huf => "Hungarian Forint", :ltl => "Lithuanian Litas", :lvl => "Latvian Lats",
                      :pln => "Polish Zloty", :ron => "New Romanian Leu", :isk => "Icelandic Krona", :hrk => "Croatian Kuna",
                      :rub => "Russian Rouble", :try => "New Turkish Lira", :php => "Philippine Peso", :cop => "Columbian Peso",
                      :ars => "Argentine Peso", :clp => "Chilean Peso", :svc => "Salvadoran colon", :tnd => "Tunisian Denar",
                      :pyg => "paraguay Guarani", :mad => "Moroccan Dirham", :jmd => "Jamaican Dollar", :sar => "Saudi Arabian Riyal",
                      :qar => "Qatari Riyal", :hnl => "Honduran Lempira", :syp => "Syrian Pound", :kwd => "Kuwaiti Dinar",
                      :bhd => "Bahrain Dinar", :egp => "Egyptian Pound", :omr => "Omani Rial", :ngn => "Nigrian Naira",
                      :pab => "Panama Balboa", :pen => "Peruvian Nuevo Sol", :uyu => "Uruguayan New Peso"}

  @@popular_curr = [:eur, :usd, :gbp, :aud, :brl, :cad, :chf, :cny, :dkk, :hkd, :inr, :jpy]

  def is_supported_curr?(curr)
    @@supported_curr.keys.include?(curr.to_sym)
  end

  def updated_at(curr)
    to_curr = @@popular_curr.find { |pc| pc != curr.to_sym }
    1.send(curr).send("to_#{to_curr}_updated_at")
  end

  def build_rates(curr)
    @currency = curr
    @currency_name = @@supported_curr[curr.to_sym]
    @rates = []
  
    if is_supported_curr?(@currency)
      @@popular_curr.each do |pc|
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
  
      @updated_at = Time.parse(updated_at(@currency)) - (60 * 60)
  
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
  etag Digest::MD5.hexdigest(@currency + @updated_at.to_s)
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
  
  unless is_supported_curr?(user_settings["currency"].downcase)
    response[:valid] = false
    response[:errors].push("We couldn't find the currency you selected (#{user_settings["currency"]}). Please select another.")
  end
  
  content_type :json
  response.to_json
end
