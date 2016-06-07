#!/usr/bin/env python
import boto
import bson
import progressbar
import re
import sys
import ujson as json

SOURCE_BUCKET = 'zooniverse-data'
DESTINATION_BUCKET = 'zooniverse-static'
DESTINATION_PATH = 'www.batdetective.org/subjects/'

try:
    SOURCE_PATH, ORIGIN = sys.argv[1:]
except ValueError:
    print "Usage: generate-manifest.py path/to/data/on/s3/ origin_country"
    sys.exit(1)

s3_conn = boto.connect_s3()
source_bucket = s3_conn.get_bucket(SOURCE_BUCKET)
destination_bucket = s3_conn.get_bucket(DESTINATION_BUCKET)

bar = progressbar.ProgressBar()
subject_manifest = []

source_subjects = {}
source_typemap = {
    'mp3': 'mp3',
    'wav.png': 'standard',
}
destination_typemap = {
    'mp3': 'mp3',
    'standard': 'png',
}

for source_file in source_bucket.list(prefix=SOURCE_PATH):
    subject_name_match = re.match(
        r'(?P<prefix>.*)\.(?P<type>(mp3|wav\.png))$',
        source_file.name
    )
    if not subject_name_match:
        continue

    source_subjects.setdefault(subject_name_match.group('prefix'), {})[
        source_typemap[subject_name_match.group('type')]
    ] = source_file

for prefix, source_subject in bar(source_subjects.items()):
    if len(source_subject) != 2:
        continue

    # Generate manifest entry
    subject = {
        '_id': str(bson.objectid.ObjectId()),
        'location': {},
        'metadata': {
            'origin': ORIGIN,
            'filename': '%s.wav' % prefix,
        },
    }

    print 'Uploading subject %s' % subject['_id']

    # Copy file on S3
    for location_type, source_key in source_subject.items():
        destination_path = '%s%s/%s.%s' % (
            DESTINATION_PATH,
            location_type,
            subject['_id'],
            destination_typemap[location_type]
        )
        subject_key = destination_bucket.copy_key(
            destination_path,
            source_key.bucket.name,
            source_key.name
        )
        subject_key.set_acl('public-read')
        subject['location'][location_type] = 'https://%s' % destination_path

    # Append to manifest
    subject_manifest.append(subject)

manifest_key = source_bucket.new_key(
    SOURCE_PATH + 'ouroboros_manifest.json'
)
manifest_key.set_contents_from_string(
    json.dumps(subject_manifest),
    policy='public-read'
)
