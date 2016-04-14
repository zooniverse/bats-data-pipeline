FROM zooniverse/ruby:2.3

WORKDIR /src/
COPY . /src/

ENTRYPOINT [ "/usr/bin/ruby" ]
