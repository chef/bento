#!/bin/sh
# WARNING: REQUIRES /bin/sh
#
# - must run on /bin/sh on solaris 9
# - must run on /bin/sh on AIX 6.x
# - if you think you are a bash wizard, you probably do not understand
#   this programming language.  do not touch.
# - if you are under 40, get peer review from your elders.
#
# Author:: Julian C. Dunn (<jdunn@getchef.com>)
# Cribbed Code From:: Lamont Granquist, Seth Chisamore, Stephen Delano & Tyler Cloke
# Copyright:: Copyright (c) 2013, Chef Software, Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Set $CHEF_VERSION inside Packer's template. Valid options are:
#   'provisionerless' -- build a box without Chef
#   'x.y.z'           -- build a box with version x.y.z of Chef
#   'latest'          -- build a box with the latest version of Chef
#   'prerelease'      -- build a box with a prerelease version of Chef

chef_installer="/tmp/install-chef.sh"
chef_installer_url="https://www.getchef.com/chef/install.sh"

# Check whether a command exists - returns 0 if it does, 1 if it does not
exists() {
  if command -v $1 >/dev/null 2>&1
  then
    return 0
  else
    return 1
  fi
}

unable_to_retrieve_package() {
  echo "Unable to retrieve install.sh!"
  if test "x$stderr_results" != "x"; then
    echo "\nDEBUG OUTPUT FOLLOWS:\n$stderr_results"
  fi
  exit 1
}

capture_tmp_stderr() {
  # spool up /tmp/stderr from all the commands we called
  if test -f "/tmp/stderr"; then
    output=`cat /tmp/stderr`
    stderr_results="${stderr_results}\nSTDERR from $1:\n\n$output\n"
    rm /tmp/stderr
  fi
}

# do_wget URL FILENAME
do_wget() {
  echo "trying wget..."
  wget -O "$2" "$1" 2>/tmp/stderr
  rc=$?
  # check for 404
  grep "ERROR 404" /tmp/stderr 2>&1 >/dev/null
  if test $? -eq 0; then
    echo "ERROR 404"
    unable_to_retrieve_package
  fi

  # check for bad return status or empty output
  if test $rc -ne 0 || test ! -s "$2"; then
    capture_tmp_stderr "wget"
    return 1
  fi

  return 0
}

# do_curl URL FILENAME
do_curl() {
  echo "trying curl..."
  curl -sL -D /tmp/stderr "$1" > "$2"
  rc=$?
  # check for 404
  grep "404 Not Found" /tmp/stderr 2>&1 >/dev/null
  if test $? -eq 0; then
    echo "ERROR 404"
    unable_to_retrieve_package
  fi

  # check for bad return status or empty output
  if test $rc -ne 0 || test ! -s "$2"; then
    capture_tmp_stderr "curl"
    return 1
  fi

  return 0
}

# do_fetch URL FILENAME
do_fetch() {
  echo "trying fetch..."
  fetch -o "$2" "$1" 2>/tmp/stderr
  # check for bad return status
  test $? -ne 0 && return 1
  return 0
}

# do_curl URL FILENAME
do_perl() {
  echo "trying perl..."
  perl -e 'use LWP::Simple; getprint($ARGV[0]);' "$1" > "$2" 2>/tmp/stderr
  rc=$?
  # check for 404
  grep "404 Not Found" /tmp/stderr 2>&1 >/dev/null
  if test $? -eq 0; then
    echo "ERROR 404"
    unable_to_retrieve_package
  fi

  # check for bad return status or empty output
  if test $rc -ne 0 || test ! -s "$2"; then
    capture_tmp_stderr "perl"
    return 1
  fi

  return 0
}

# do_curl URL FILENAME
do_python() {
  echo "trying python..."
  python -c "import sys,urllib2 ; sys.stdout.write(urllib2.urlopen(sys.argv[1]).read())" "$1" > "$2" 2>/tmp/stderr
  rc=$?
  # check for 404
  grep "HTTP Error 404" /tmp/stderr 2>&1 >/dev/null
  if test $? -eq 0; then
    echo "ERROR 404"
    unable_to_retrieve_package
  fi

  # check for bad return status or empty output
  if test $rc -ne 0 || test ! -s "$2"; then
    capture_tmp_stderr "python"
    return 1
  fi
  return 0
}

do_download() {
  echo "downloading $1"
  echo "  to file $2"

  # we try all of these until we get success.
  # perl, in particular may be present but LWP::Simple may not be installed

  if exists wget; then
    do_wget $1 $2 && return 0
  fi

  if exists curl; then
    do_curl $1 $2 && return 0
  fi

  if exists fetch; then
    do_fetch $1 $2 && return 0
  fi

  if exists perl; then
    do_perl $1 $2 && return 0
  fi

  if exists python; then
    do_python $1 $2 && return 0
  fi

  unable_to_retrieve_package
}

if [ x$CHEF_VERSION != x'provisionerless' ]; then
  do_download "$chef_installer_url" "$chef_installer"
  chmod +x $chef_installer
  if [ x$CHEF_VERSION == x'latest' ]; then
    $chef_installer
  elif [ x$CHEF_VERSION == x'prerelease' ]; then
    $chef_installer -p
  else
    $chef_installer -v $CHEF_VERSION
  fi
  rm -f $chef_installer
else
  echo "Building a box without Chef"
fi
