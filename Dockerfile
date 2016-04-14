FROM zooniverse/ruby

WORKDIR /src/
COPY . /src/

ENTRYPOINT [ "/usr/bin/ruby" ]
