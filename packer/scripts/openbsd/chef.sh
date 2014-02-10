if [ x$CHEF_VERSION = x'provisionerless' ]; then
  echo "Building a box without Chef"
else
  . /root/.profile
  pkg_add ruby-1.9.3.448

  for f in ruby erb irb rdoc ri rake gem testrb \
           chef-apply chef-client chef-shell chef-solo chef-zero \
           knife ohai shef; do
    ln -sf ${f}19 /usr/local/bin/$f
  done

  ln -sf /usr/local/bin/testrb19 /usr/local/bin/testrb

  if [ x$CHEF_VERSION == x'latest' ]; then
    gem install chef --no-ri --no-rdoc
  elif [ x$CHEF_VERSION == x'prerelease' ]; then
    gem install chef --no-ri --no-rdoc --pre
    $chef_installer -p
  else
    gem install chef --no-ri --no-rdoc --version="$CHEF_VERSION"
  fi
fi
