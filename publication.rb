require "sinatra"

get "/edition/" do
  etag Digest::MD5.hexdigest("edition")
  erb :rates
end

get "/sample/" do
  etag Digest::MD5.hexdigest("sample")
  erb :rates
end
