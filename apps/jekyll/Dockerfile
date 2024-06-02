# /usr/local/bundle
from docker.io/ruby:3.3-slim as builder
RUN sed -i 's/deb.debian.org/mirrors.aliyun.com/g' /etc/apt/sources.list.d/debian.sources
RUN apt update && apt-get install build-essential -y
RUN gem sources --add https://gems.ruby-china.com/ --remove https://rubygems.org/
RUN bundle config mirror.https://rubygems.org https://gems.ruby-china.com
RUN gem sources -l && gem install jekyll bundler
from docker.io/ruby:3.3-slim
COPY --from=builder /usr/local/bundle /usr/local/bundle
RUN sed -i 's/deb.debian.org/mirrors.aliyun.com/g' /etc/apt/sources.list.d/debian.sources \
    && gem sources --add https://gems.ruby-china.com/ --remove https://rubygems.org/ \
    && bundle config mirror.https://rubygems.org https://gems.ruby-china.com

# docker build --force-rm -m 2g -t softlang/jekyll:ruby3.3-slim -f Dockerfile /usr/games/

