require "sinatra"
require "active_support/core_ext/integer/inflections"

supported_curr= ["eur", "usd", "gbp", "aud", "brl", "cad", "chf", "cny", "dkk", "hkd", "inr", "jpy", "krw",
                 "lkr", "myr", "nzd", "sgd", "twd", "zar", "thb", "sek", "nok", "mxn", "bgn", "czk", "huf",
                 "ltl", "lvl", "pln", "ron", "isk", "hrk", "rub", "try", "php", "cop", "ars", "clp", "svc",
                 "tnd", "pyg", "mad", "jmd", "sar", "qar", "hnl", "syp", "kwd", "bhd", "egp", "omr", "ngn",
                 "pab", "pen", "uyu"]

get "/edition/" do
  etag Digest::MD5.hexdigest("edition")
  erb :rates
end

get "/sample/" do
  etag Digest::MD5.hexdigest("sample")
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
