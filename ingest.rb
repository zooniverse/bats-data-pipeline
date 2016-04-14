require 'bson'
require 'connection_pool'
require 'json'
require 'mysql2'
require 'yaml'

config = YAML.load_file File.join Dir.pwd, 'config.yml'

mysql = ConnectionPool.new(size: 4) {
  Mysql2::Client.new(
    host: config['mysql']['hostname'],
    username: config['mysql']['username'],
    password: config['mysql']['password'],
    database: config['mysql']['database']
  )
}

puts "Running ingest..."
Dir.entries(config['manifest_location']).each do |entry|
  next if ['.', '..'].include? entry

  puts "Ingesting #{ entry }..."

  manifest = File.readlines File.join config['manifest_location'], entry
  total = manifest.length

  manifest.each.with_index do |subject_location, index|
    puts "#{ index + 1 } / #{ total }"

    bson_id = BSON::ObjectId.new.to_s
    filename = File.basename(subject_location).strip
    location = File.join config['remote']['bucket'], config['remote']['path']
    country = File.basename entry, '.*'

    mysql.with do |conn|
      conn.query <<-SQL
        insert into subjects
          (bson_id, filename, location, country)
        values (
          '#{ bson_id }',
          '#{ filename }',
          '#{ location }',
          '#{ country }'
        )
      SQL
    end
  end
end
