require 'json'
require 'mysql2'
require 'yaml'

config = YAML.load_file File.join Dir.pwd, 'config.yml'

mysql = Mysql2::Client.new(
    host: config['mysql']['hostname'],
    username: config['mysql']['username'],
    password: config['mysql']['password'],
    database: config['mysql']['database']
  )

output = File.new 'manifest.txt', 'w+'

results = mysql.query("select * from subjects")
total = results.count
count = 0

results.each do |subject_row|
  puts "#{ count += 1 } / #{ total }"

  subject = {
    _id: subject_row['bson_id'],
    location: {
      standard: "http://www.batdetective.org/subjects/standard/#{ subject_row['bson_id'] }.png",
      mp3: "http://www.batdetective.org/subjects/mp3/#{ subject_row['bson_id'] }.mp3"
    },
    metadata: {
      filename: subject_row['filename'],
      origin: subject_row['origin']
    }
  }

  output.puts JSON.dump subject
end
