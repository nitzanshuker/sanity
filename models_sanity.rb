
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

  def model_parts(input)

    res = input

    x = res.split(' ').length
    puts x

    res = input.split(" ")

    base_word = res[0..1]
    p base_word

    final_modles_array = []
    final_modles_array.push(base_word.join(" "))

    res.each_with_index do |item, index|
      next if index <= 1
      base_word << item
      final_modles_array.push(base_word.join(" "))
      p final_modles_array.last
    end

    return final_modles_array


  end


  def run(num)


  client = Mongo::Client.new([ '127.0.0.1:27017' ], :database => 'marketpulzz')

  collection = :retailer_products
  p client[collection].find

  api_key = "QN3ErGYvmNznlOZXBcHgYQtt"

  dn = client[collection].find({deleted:false}, {:fields =>{name:1, product_type:1}}).limit(num)
  dn.each do |doc|
    puts "#{doc['name']} , #{doc['product_type']}"

    hello, code = call_api(doc['name'], api_key)
    puts hello

    all_phrases = model_parts(doc['name'])
    puts all_phrases

    all_phrases.each do |phrase|
      nlu, code = call_api(phrase, api_key)
      nlu = JSON.parse(nlu)
      puts nlu

      models = models_in_the_nlu(nlu)
      
    end

    break

  end

end


def models_in_the_nlu(nlu)
  models_nlu = nlu["result"]["positive"]["models"] rescue []
  models_nlu.each do |model|
    puts model
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

