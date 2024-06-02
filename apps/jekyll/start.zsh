#!/bin/bash
set -e

cwd=$(realpath $(dirname $0))
mkdir -p $cwd/data
pushd $cwd

docker run -itd --name jekyll -h jekyll --cpus 2 -m 2048m \
    --network app -p 4000:4000 -e TZ=Asia/Shanghai \
    -v ./data/:/data -w /data docker.io/ruby:3.3-slim
#docker.io/ubuntu:24.04


<<'comments'
# https://jekyllrb.com/docs/installation/ubuntu/
apt-get install ruby-full build-essential zlib1g-dev

echo '# Install Ruby Gems to ~/gems' >> ~/.bashrc
echo 'export GEM_HOME="$HOME/gems"' >> ~/.bashrc
echo 'export PATH="$HOME/gems/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc

gem sources --add https://gems.ruby-china.com/ --remove https://rubygems.org/
gem sources -l

gem install jekyll bundler

bundle config mirror.https://rubygems.org https://gems.ruby-china.com
cat ~/.bundle/config

# quick start
# https://jekyllrb.com/docs/
gem install jekyll bundler
jekyll new myblog
cd myblog
bundle exec jekyll serve -H 0.0.0.0 -p 4000 -b /pubcrm/
comments
