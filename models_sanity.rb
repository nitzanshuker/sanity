
require 'mongo'
require 'csv'
require 'mail'
require 'uri'
require 'net/http'
require 'json'

class ModelSanity


  def initialize

  p "yaron is awesome!!!"

  end


def run(num)


  client = Mongo::Client.new([ '127.0.0.1:27017' ], :database => 'marketpulzz')

  collection = :retailer_products
  p client[collection].find

  api_key = "QN3ErGYvmNznlOZXBcHgYQtt"

  dn = client[collection].find({deleted:false}, {:fields =>{name:1, product_type:1}}).limit(num)
  dn.each do |doc|
    puts "#{doc['name']} , #{doc['product_type']}"
    text, code = call_api(doc['name'], api_key)
    puts text
    
  end
end


def call_api(text, api_key)

  uri = URI("https://satool-test.mmuze.com/v1/conversations/")
  https = Net::HTTP.new(uri.host, uri.port)
  https.use_ssl = true
  headers = {'Content-Type' => 'application/json' , 'X-Api-Key' => api_key}

  data = {"text" => text}


  response = https.post(uri.path,JSON.generate(data),headers)
  response_text = response.body
  response_text.force_encoding('UTF-8')
  #response_text.gsub! /â„¢/, '™'

  return [response_text, response.code]

end



end

if __FILE__ == $0

  p "running nitzans function"
  nitzans_object = ModelSanity.new
  num_from_user = ARGV[0].to_i
  qa_email  = ARGV[1]
  user_env = ARGV[2]
  retailer_id = ARGV[3]

  p num_from_user, qa_email, user_env, retailer_id
  nitzans_object.run(num_from_user)


end

