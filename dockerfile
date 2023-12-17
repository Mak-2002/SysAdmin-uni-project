FROM ubuntu:latest

RUN apt-get update && \
    apt-get install -y bash tar gzip

WORKDIR /app

COPY . /app

CMD ["/bin/bash"]
