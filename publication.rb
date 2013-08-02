require "sinatra"
require "active_support/core_ext/integer/inflections"

get "/edition/" do
  etag Digest::MD5.hexdigest("edition")
  erb :rates
end

get "/sample/" do
  etag Digest::MD5.hexdigest("sample")
  erb :rates
end
