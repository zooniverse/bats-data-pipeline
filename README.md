# bats-data-pipeline

Imports Ouroboros data for Bat Detective.

## Overview

```
docker run -it --rm -v $PWD/config.yml:/src/config.yml zooniverse/bats-data-pipeline ingest.rb
docker run -it --rm -v $PWD/config.yml:/src/config.yml zooniverse/bats-data-pipeline generate_manifest.rb
docker run -it --rm -v $PWD/config.yml:/src/config.yml zooniverse/bats-data-pipeline process.rb
docker run -it --rm -v $PWD/config.yml:/src/config.yml zooniverse/bats-data-pipeline builder.rb
```
