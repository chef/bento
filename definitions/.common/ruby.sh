#!/bin/bash -eux

wget -O- http://pyyaml.org/download/libyaml/yaml-0.1.4.tar.gz | tar oxz
cd yaml*
./configure --prefix=/opt/ruby
make && make install
cd ..
rm -rf *yaml*

wget -O- http://ftp.ruby-lang.org/pub/ruby/1.9/ruby-1.9.2-p290.tar.gz | tar oxz
cd ruby*
./configure --prefix=/opt/ruby --with-opt-dir=/opt/ruby
make && make install
/opt/ruby/bin/gem update --system
/opt/ruby/bin/gem update
/opt/ruby/bin/gem clean
/opt/ruby/bin/gem install chef puppet --no-rdoc --no-ri
cd ..
rm -rf *ruby*

echo 'PATH=$PATH:/opt/ruby/bin' > /etc/profile.d/ruby.sh
