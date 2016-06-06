 # Does the Ouroboros ingestion thing.

unless ARGV.length == 1
  puts "Must provide a path to a manifest file."
  puts "Ex. rails r ./builder.rb ./manifest.txt"
  exit
end

manifest_path = ARGV[0]

unless File.exist?(manifest_path)
  puts "Could not locate manifest."
  exit
end

begin
  raw_subjects = JSON.parse(File.read(manifest_path))
rescue
  puts "Error trying to parse the manifest file."
  exit
end

total = raw_subjects.count
i = 0

project = Project.where(name: 'bat_detective')
workflow = project.workflows.first

raw_subjects.each do |raw_subject|
  puts "#{ i +=1 } / #{ total }"

  bson_id = BSON::ObjectId(subject['_id'])

  subject = {
    _id: bson_id,
    project: project.id,
    workflows: [workflow.id],
    location: raw_subject['location'],
    metadata: raw_subject['metadata']
  }

  unless BatDetectiveSubject.where(_id: bson_id).exists?
    BatDetectiveSubject.create(subject).pause!
  end
end
