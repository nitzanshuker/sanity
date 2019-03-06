
require 'mongo'
require 'csv'
require 'mail'
require 'uri'
require 'net/http'
require 'json'

class ModelSanity

  RETAILER_ID_API_KEY_MAP = {

      "324" => "QN3ErGYvmNznlOZXBcHgYQtt", # elc staging
      "327" => "Tm9ATBDWYUrJVFQ4IiExQwtt", # elc production
      "213" => "ewzTULzmuV1uGunELvojZQtt", # Shimona
      "441" => "ccoSZU0qzMF1QHbumhazrwtt", # OP staging
      "429" => "QL4imKcGa9wEVs9O4CW00wtt", # OP offical production
      "272" => "trUw10iqq2I8N4RkxV28qQtt", # Shimon
  }




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
      model_parts_combos = base_word.join(" ").downcase
   # if model_parts_combos == @product_type
    #   next
    # else
   #    p "no models for this product"
   # end
      next if index <= 1
      base_word << item
      final_modles_array.push(base_word.join(" "))
      p final_modles_array.last
    end

    return final_modles_array
  end


  def run(num)



    CSV.open("/home/shuker/RubymineProjects/file.csv", "wb",
             :write_headers=> true,
             :headers => ["product name","models combination","pass?", "actual models"]) do |csv|

  client = Mongo::Client.new([ '127.0.0.1:27017' ], :database => 'marketpulzz')

  collection = :retailer_products
  p client[collection].find

  api_key = RETAILER_ID_API_KEY_MAP["324"]
  #api_key = "QN3ErGYvmNznlOZXBcHgYQtt"

  retailer_products_from_query = client[collection].find({deleted:false}, {:fields =>{name:1, product_type:1}}).limit(num)
  retailer_products_from_query.each do |doc|
    product_name = doc['name']
    @product_type = doc['product_type']
    puts "#{product_name} , #{doc['product_type']}"

    hello, code = call_api(product_name, api_key)
    puts hello


    all_phrases = model_parts(product_name)

    puts all_phrases

    all_phrases.each do |phrase|
      nlu, code = call_api(phrase, api_key)
      nlu = JSON.parse(nlu)
      puts nlu

      models = models_in_the_nlu(nlu)
      puts models


      # check if 'product_name' included in 'models'
      if models.include?(product_name)
          pass = true
      else
        pass = false
      end
      p pass

      csv <<[product_name, phrase, pass, models]
    end

      end
  end


  end



def models_in_the_nlu(nlu)
  models_nlu = nlu["result"]["positive"]["models"] rescue []
  models_nlu.each do |model|
    puts model

  end

  return models_nlu

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

