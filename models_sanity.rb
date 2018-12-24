
require 'mongo'


class ModelSanity


  def initialize
  p "yaron is awesome!!!"
  end


  def run(num)


    client = Mongo::Client.new([ '127.0.0.1:27017' ], :database => 'marketpulzz')

    collection = :retailer_products
    p client[collection].find

    dn = client[collection].find({retailer_id:"324", deleted:false}, {:fields =>{name:1, product_type:1}}).limit(num)
    dn.each { |doc| puts "#{doc['name']} , #{doc['product_type']}" }

  end

end

if __FILE__ == $0

  p "running nitzans function"
  nitzans_object = ModelSanity.new
  num_from_user = ARGV[0].to_i
  qa_email  = ARGV[1]
  user_env = ARGV[2]

  p num_from_user, qa_email, user_env
  nitzans_object.run(num_from_user)


end

