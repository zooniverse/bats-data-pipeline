require 'mysql2'
require 'yaml'

# The only thing we need to do to "process" the data is to move them around on S3.
# Implicitly requires the AWS CLI. Because I like the format better for this type of stuff.

config = YAML.load_file File.join Dir.pwd, 'config.yml'

mysql = Mysql2::Client.new(
    host: config['mysql']['hostname'],
    username: config['mysql']['username'],
    password: config['mysql']['password'],
    database: config['mysql']['database']
  )

results = mysql.query("select * from subjects")
total = results.count
count = 0

results.each do |raw_subject|
  puts "#{ count += 1 } / #{ total }"

  # These are fragile and I hate them.

  basename = File.basename raw_subject['filename'], '.*'
  country = raw_subject['country']

  # For sound
  source = "#{ config['remote']['bucket'] }/#{ config['remote']['path'] }/#{ country }/#{ basename }.mp3"
  destination = "#{ config['destination']['bucket'] }/#{ config['destination']['path'] }/mp3/#{ raw_subject['bson_id'] }.mp3"

  `aws s3 cp s3://#{ source } s3://#{ destination } --acl public-read`

  # For picture
  source = "#{ config['remote']['bucket'] }/#{ config['remote']['path'] }/#{ country }/#{ basename }.wav.png"
  destination = "#{ config['destination']['bucket'] }/#{ config['destination']['path'] }/standard/#{ raw_subject['bson_id'] }.png"

  `aws s3 cp s3://#{ source } s3://#{ destination } --acl public-read`
end
