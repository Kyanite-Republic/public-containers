FROM debian:bookworm-slim

RUN apt-get update && apt-get full-upgrade -y && apt-get install -y curl unzip tar
RUN curl -fL https://getcli.jfrog.io | sh && chmod +x jfrog && mv jfrog /usr/local/bin/